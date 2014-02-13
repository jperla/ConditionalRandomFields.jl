require("crflib.jl")
require("viterbi.jl")

import Logging: info, INFO
Logging.configure(level=INFO)

########################################################################
# Contrastive divergence  Algorithm for Approximating Training of CRFs
########################################################################

type ContrastiveDivergenceCRF <: ConditionalRandomFieldClassifier
    # input parameters:
    tags::Vector{Tag}
    features::Features
    lambda::Float64 # learning rate
    n_iter::Int

    # calculated parameters:
    w_::Vector{Weight}
end

ContrastiveDivergenceCRF(tags::Vector{Tag}, f::Features, l::Float64, n::Int) = ContrastiveDivergenceCRF(tags, f, l, n, zeros(num_features(f)))

function score{T <: String}(crf, x::Array{T}, label::Array{Tag})
    assert(length(crf.w_) == num_features(crf.features))
    s = 0
    J = num_features(crf.features)
    for j = 1:J
        s += (crf.w_[j] * evaluate_feature(crf.features, j, x, label))
    end
    return s
end

function gibbs{T <: String}(crf::ContrastiveDivergenceCRF, x::Array{T}, start_label::Array{Tag})
    n = length(x)
    m = length(crf.tags)

    label = deepcopy(start_label)

    # for each position pick best label[i] conditioned on other labels
    for i in 1:n
        temp_label = label
        best_score = -1000000
        for j=1:m
            temp_label[i] = crf.tags[j]
      
            new_score = score(crf, x, temp_label)
      
            if new_score >= best_score
                best_score = new_score
                label[i] = crf.tags[j]
            end
        end
    end
    return label
end

function cd_parallel_compute_next_weights{T <: String}(crf::ContrastiveDivergenceCRF, x::Array{T}, true_label::Array{Tag})
    J = num_features(crf)
    sparse_merge = make_sparse_merge(J)

    predicted_label = gibbs(crf, x, true_label)
    new_weights = @parallel sparse_merge for j in 1:J
        predictedF = evaluate_feature(crf.features, j, x, predicted_label)
        trueF = evaluate_feature(crf.features, j, x, true_label)
        (j, crf.lambda * (trueF - predictedF))
    end
    return crf.w_ + new_weights
end

function fit!(crf::ContrastiveDivergenceCRF, data::Sentences, labels::Labels; test_data::Sentences = [], test_labels::Labels = [])
    return fit!(crf, data, labels, cd_parallel_compute_next_weights, test_data=test_data, test_labels=test_labels)
end

# TODO: jperla: maybe put these into crflib more generally? (also score and fit!)
function num_features(crf::ContrastiveDivergenceCRF)
    return num_features(crf.features)
end
function predict{T <: String}(classifier::ContrastiveDivergenceCRF, sentence::Vector{T})
    predicted_label = predict_label(classifier.w_, classifier.features, sentence, classifier.tags)
    return predicted_label
end
