include("features.jl")

using Logging
Logging.configure(level=INFO)

abstract Classifier
abstract ConditionalRandomFieldClassifier <: Classifier

function viterbi{T <: String}(w::Array{Float64}, features::Features, sentence::Array{T})
    n = length(sentence)
    labels = vcat(Tag[SPACE for i in 1:(n-1)], Tag[PERIOD])
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
    w_::Vector{Float64}
end

function num_features(crf::CollinsPerceptronCRF)
    return num_features(crf.features)
end

function true_and_predicted(classifier::CollinsPerceptronCRF, data::Function, labels::Function, i::Int)
    true_label = labels(i)
    predicted_label = viterbi(classifier.w_, classifier.features, data(i))
    assert(length(true_label) == length(predicted_label))
    return true_label, predicted_label
end


function evaluate_feature{T <: String}(features::Features, feature_j::Index, x_no_start::Array{T}, y_no_start::Array{Tag})
    x = vcat(T[utf8("")], x_no_start)
    y = vcat([START], y_no_start)
    assert(length(x) == length(y))
    sum = 0
    for i in 2:length(x)
        sum += evaluate_feature(features, feature_j, i, x, y[i], y[i-1])
    end
    return sum
end

function fit!(classifier::CollinsPerceptronCRF, data::Function, labels::Function, N::Int)
    # Data and Labels are functions which take a single integer argument in (1,N)
    J = num_features(classifier)
    classifier.w_ = zeros(J)
    for iter in 1:classifier.n_iter
        for i in 1:N
            x = data(i)
            true_label, predicted_label = true_and_predicted(classifier, data, labels, i)
            for j in 1:J
                classifier.w_[j] = classifier.w_[j] + evaluate_feature(classifier.features, j, x, true_label) - evaluate_feature(classifier.features, j, x, predicted_label)
            end
        end

        # calculate the new number we have correct after every epoch (should improve ~ each epoch)
        num_correct = 0
        for i in 1:N
            true_label, predicted_label = true_and_predicted(classifier, data, labels, i)
            if true_label == predicted_label
                num_correct += 1
            end
        end
        info("epoch $iter: $num_correct / $N")
    end
end

function predict{T <: String}(classifier::CollinsPerceptronCRF, sentence::Array{T})
    return viterbi(classifier.w_, classifier.features, sentence)
end

