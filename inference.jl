include("features.jl")
include("crflib.jl")
include("tags.jl")

import Logging: info, debug, INFO
Logging.configure(level=INFO)

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################

function best_label(last_index::Int, previous_tags::Array{Int, 2}, input_tags::Array{Tag})
  tag_index = indices(input_tags)

  debug("previous tags: $previous_tags")

  (n, m) = size(previous_tags)

  result = Tag[input_tags[last_index]]
  # prepend!(result, [last_tag])

  debug("n: $n, m: $m")

  for i = n:-1:2

    last_index = previous_tags[i, last_index]
    result = prepend!(result, [input_tags[last_index]])
    
   end

  return result
end


function best_last_tag(s_lookup::Array{Float64,2})
  (n,m) = size(s_lookup)
  max = 0
  best_last = 1
  for i = 1:m
    if s_lookup[n, i] >= max
      max = s_lookup[n, i]
      best_last = i
    end
  end
  debug("best last: $best_last")
  return best_last
end


function predict_label{T <: String}(weights::Array{Weight}, features::Features, x::Array{T}, input_tags::Array{Tag})
  ##########################################################################
  #   Compute U(k,v) matrix   U(k,v)  = max over u of [ U(k-1, u) + gk(u,v) ]
  ##########################################################################
  m = length(input_tags)
  n = length(x)
  s_lookup = zeros(n, m)
  previous_tags = zeros(Int64, n, m)

  tag_index = indices(input_tags)
  for k = 1:n
    ######################################################################
    #  take max
    #######################################################################
    for v = 1:m
      prev_tag = 0
      max = 0
      for u = 1:m

        if k == 1
          yt_before = tag_index[START]
          base = 0
        else
          yt_before = u
          base = s_lookup[k-1, u]
        end

        potential_s = base + g_function(weights, features, k, x, input_tags[v], input_tags[yt_before])

        if potential_s >= max
          max = potential_s
          previous_tags[k, v] = yt_before
        end
      end

      debug("max_score: $max")
      s_lookup[k, v] = max
      debug("tag before: $prev_tag")
    end
  end

  last_index = best_last_tag(s_lookup)
  best = best_label(last_index, previous_tags, input_tags)
  debug("best length: $(length(best))  input: $(length(x)) n: $n") 
  return best
end

function g_function{T <: String}(weights::Array{Weight}, features::Features, i::Index, x::Array{T}, yt::Tag, yt_before::Tag)
  J = num_features(features)
  g = 0

  for j = 1:J
    g += weights[j] * evaluate_feature(features, j, i, x, yt, yt_before )
  end
  return g
end

function g_matrix{T <: String}(weights::Array{Weight}, features::Features, i::Index, x::Array{T}, yt::Tag, yt_before::Tag)
  g_grid = zeros(m,m)
  for k in 1:m
    for l in 1:m
       g_grid[k,l] = g_function(weights, features, i, x, all_tags[k], all_tags[l] )
    end
  end
  return g_grid
end

