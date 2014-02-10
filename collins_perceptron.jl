include("features.jl")
include("crflib.jl")

using Logging
Logging.configure(level=INFO)

# TODO: Zach: make this not broken
function viterbi{T <: String}(w::Vector{Weight}, features::Features, sentence::Vector{T})
    n = length(sentence)
    labels::Vector{Tag} = vcat(Tag[SPACE for i in 1:(n-1)], Tag[PERIOD])
    assert(length(labels) == length(sentence))
    return labels
end

####################################################################
# Collins Perceptron Algorithm for Approximating Training of CRFs
#
# http://acl.ldc.upenn.edu/W/W02/W02-1001.pdf
####################################################################

type CollinsPerceptronCRF <: ConditionalRandomFieldClassifier
    # input parameters:
    features::Features
    n_iter::Int
    # calculated parameters:
    w_::Vector{Weight}
end

# Defaults to w_ vector filled with num_features 0s
CollinsPerceptronCRF(f::Features, n::Int) = CollinsPerceptronCRF(f, n, zeros(num_features(f)))

function num_features(crf::CollinsPerceptronCRF)
    return num_features(crf.features)
end

function predict{T <: String}(classifier::CollinsPerceptronCRF, sentence::Vector{T})
    predicted_label = viterbi(classifier.w_, classifier.features, sentence)
    return predicted_label
end

function fit!(crf::CollinsPerceptronCRF, data::Function, labels::Function, N::Int)
    # Data and Labels are functions which take a single integer argument in (1,N)
    J = num_features(crf)
    crf.w_ = zeros(J) # re-initialize to 0 for every fit
    for iter in 1:crf.n_iter
        for i in 1:N
            x, true_label = data(i), labels(i)
            predicted_label = predict(crf, x)
            for j in 1:J
                predictedF = evaluate_feature(crf.features, j, x, predicted_label)
                trueF = evaluate_feature(crf.features, j, x, true_label)
                crf.w_[j] = crf.w_[j] + trueF - predictedF
            end
        end

        # Debugging: should improve after each epoch
        n = num_correct_labels(crf, data, labels, N)
        info("epoch $iter: $n / $N")
    end
end
