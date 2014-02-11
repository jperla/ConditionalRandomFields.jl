include("features.jl")
include("crflib.jl")

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################


function best_label(last_tag, previous_tags::Array{Float64, 2})

  result = [last_tag]

  tag_to_add = last_tag
  for i = n:-1:1
    tag_to_add = previous_tags[i, last_tag]
    prepend!(result, last_tag)

  end
end


function predict_label{T <: String}(weights::Array{Weight}, features::Features, x::Array{T}, input_tags::Array{Tag})

  ##########################################################################
  #   Compute U(k,v) matrix   U(k,v)  = max over u of [ U(k-1, u) + gk(u,v) ]
  ##########################################################################
  m = length(input_tags)
  n = length(x)
  s_lookup = zeros(n,m)
  previous_tags = zeros(n,m)


  for k = 1:n
    ######################################################################
    #  take max
    #######################################################################
    for v = 1:m

      if k == 1
        yt_before = START
      end
      max = 0
      for u = 1:m
        if k = 1
          yt_before = START
        else
          yt_before = input_tags[u]
        end
        if k = 1
          base = 0
        else
          base = s_lookup[]
        end
        potential_s = base + g_function(weights, features, k, x, input_tags[v], yt_before)
        if potential_s > max
          max = potential_s
          tag_before = u
        end
      end
      println("max_score: $max")
      s_lookup[k,v] = max
      previous_tags[k,v] = tag_before
      println("tag before: $tag_before")
    end
  end

  return best_label(last_tag, previous_tags)

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




