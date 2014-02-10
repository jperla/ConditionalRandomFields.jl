include("featurelib.jl")
include("tags.jl")

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################



function predict_label{T <: String}(weights::Array{Float64}, features::Features, x::Array{T}, input_tags::Array{Int})

  ####################################################################################################
  #   Compute U(k,v) matrix
  #
  #    U(k,v)  = max over u of [ U(k-1, u) + gk(u,v) ]
  ####################################################################################################

  m = length(input_tags)
  n = length(x)
  s_lookup = zeros(n,m)
  previous_tags = zeros(n,m)

  for i = 2:n

    ############################################################################################################
    #  take max
    ############################################################################################################
    for v = 1:m
      max = 0
      for u = 1:m
        potential_s = s_lookup[i-1, u] + g_function(weights, features, i, x, yt=input_tags[v], yt_before=input_tags[u])
        if potential_s > max
          max = potential_s
          tag_before = u
        end
      end

      s_lookup[i,v] = max
      previous_tags[i,v] = tag_before

    end

  end

  ###########################################################################################################
  #   Retireve best score
  ###########################################################################################################

   best_score = 0
   final tag = 0
    for j = 1:m
      if s_lookup[n,j] > score
        score = s_lookup[n,j]
        final_tag = j
      end
   end

  ###########################################################################################################
  #   Retireve best label
  ###########################################################################################################


  best_label = [j]
  for i = n-1:-1:2

    prepend!(best_label, previous_tags[n-i, best_label[1]])

  return (best_score, best_label)



end



function g_function{T <: String}(weights::Array{Float64}, features::Features, i::Index, x::Array{T}, yt::Tag, yt_before::Tag)

  J = num_features(feature_function)
  g = 0

  for j = 1:J
    g += weight[l] * evaluate_feature(features, j, i, x, yt, yt_before )
  end
  return g

end

function g_matrix(weights::Array{Float64}, features::Features, i::Index, x::Array{T}, yt::Tag, yt_before::Tag)

  g_grid = zeros(m,m)
  for k in 1:m
    for l in 1:m
       g_grid[k,l] = g_function(weights, features, i, x, yt=all_tags[k], yt_before=all_tags[l] )
    end
  end
  return g_grid
end




