include("features.jl")
include("crflib.jl")

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################



function predict_label{T <: String}(weights::Array{Weight}, features::Features, x::Array{T}, input_tags::Array{Tag})

  ##############################################################################
  #   Compute U(k,v) matrix   U(k,v)  = max over u of [ U(k-1, u) + gk(u,v) ]
  ###############################################################################
  m = length(input_tags)
  n = length(x)
  s_lookup = zeros(n,m)
  previous_tags = zeros(n,m)

  for i = 2:n
    #############################################################################
    #  take max
    ############################################################################
    for v = 1:m
      max = 0
      tag_before = all_tags[1] # initialize
      for u = 1:m
        potential_s = s_lookup[i-1, u] + g_function(weights, features, i, x, input_tags[v], input_tags[u])
        if potential_s > max
          max = potential_s
          tag_before = u
        end
      end
      s_lookup[i,v] = max
      previous_tags[i,v] = tag_before
    end
  end

  ##############################################################################
  #   Retireve best score
  ##############################################################################
  best_score = 0
  final_tag = 0
  for j = 1:m
    if s_lookup[n,j] > best_score
      best_score = s_lookup[n,j]
      final_tag = j
    end
  end

  ########################################################################
  #   Retrieve best label
  ########################################################################
  # best_label = [final_tag]
  # for i = n-1:-1:2
  #   prepend!(best_label, previous_tags[n-i, best_label[1]])
  # end
  best_label = Tag[]
  for i = 1:n
    push!(best_label, SPACE)
  end
  return best_label
  
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




