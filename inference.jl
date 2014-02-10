include("featurelib.jl")
include("tags.jl")

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################


m = length(all_tags)



function predict_label{T <: String}(weights::Array{Float64}, features::Features, x::Array{T})

  ####################################################################################################
  #   Compute U(k,v) matrix
  ####################################################################################################
  n = length(x)

  u_lookup = zeroes(n,m)

end



# function z_normalization( x::Array(T), w::Array(Float) )

#   #
#   #   sum over all y
#   #
#   for y

# end

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




