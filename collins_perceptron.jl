require("crflib.jl")
require("viterbi.jl")

import Logging: info, INFO
Logging.configure(level=INFO)

####################################################################
# Collins Perceptron Algorithm for Approximating Training of CRFs
#
# http://acl.ldc.upenn.edu/W/W02/W02-1001.pdf
####################################################################

type CollinsPerceptronCRF <: ConditionalRandomFieldClassifier
    # input parameters:
    tags::Vector{Tag}
    features::Features
    n_iter::Int
    # calculated parameters:
    w_::Vector{Weight}
end

# Defaults to w_ vector filled with num_features 0s
CollinsPerceptronCRF(tags::Vector{Tag}, f::Features, n::Int) = CollinsPerceptronCRF(tags, f, n, zeros(num_features(f)))

function num_features(crf::CollinsPerceptronCRF)
    return num_features(crf.features)
end

function predict{T <: String}(classifier::CollinsPerceptronCRF, sentence::Vector{T})
    predicted_label = predict_label(classifier.w_, classifier.features, sentence, classifier.tags)
    return predicted_label
end

function parallel_compute_next_weights{T <: String}(crf::CollinsPerceptronCRF, x::Array{T}, true_label::Array{Tag})
    J = num_features(crf)
    sparse_merge = make_sparse_merge(J)

    predicted_label = predict(crf, x)
    if predicted_label != true_label
        new_weights = @parallel sparse_merge for j in 1:J
            predictedF = evaluate_feature(crf.features, j, x, predicted_label)
            trueF = evaluate_feature(crf.features, j, x, true_label)
            (j, trueF - predictedF)
        end
        return crf.w_ + new_weights
    else
        return crf.w_
    end
end

function fit!(crf::CollinsPerceptronCRF, data::Sentences, labels::Labels; test_data::Sentences = [], test_labels::Labels = [])
    return fit!(crf, data, labels, parallel_compute_next_weights, test_data=test_data, test_labels=test_labels)
end

