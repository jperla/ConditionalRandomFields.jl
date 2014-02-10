include("util.jl")

###########################################################
#   viterbi for computing yhat over all possible labels
###########################################################

function predict_label(weights::Array{Int}, feature_function, x_seq=Array{T})

  yhat = ["label", "will", "go", "here"]



end



# function z_normalization( x::Array(T), w::Array(Float) )

#   #
#   #   sum over all y
#   #
#   for y

# end

function g_function (yt::Tag, ytbefore::Tag, weights::Array{Float}, )
