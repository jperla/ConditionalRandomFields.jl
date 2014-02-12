include("crflib.jl")
include("viterbi.jl")

import Logging: info, INFO
Logging.configure(level=INFO)

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

function predict{T <: String}(classifier::CollinsPerceptronCRF, sentence::Vector{T}, tags::Array{Tag})
    predicted_label = predict_label(classifier.w_, classifier.features, sentence, tags)
    return predicted_label
end

function fit!(crf::CollinsPerceptronCRF, data::Function, labels::Function, N::Int, tags::Array{Tag})
    # Data and Labels are functions which take a single integer argument in (1,N)
    J = num_features(crf)
    crf.w_ = zeros(J) # re-initialize to 0 for every fit
    for iter in 1:crf.n_iter
        for i in 1:N
            x, true_label = data(i), labels(i)
            info("example $i")
            predicted_label = predict(crf, x, tags)
            for j in 1:J
                predictedF = evaluate_feature(crf.features, j, x, predicted_label)
                trueF = evaluate_feature(crf.features, j, x, true_label)
                crf.w_[j] = crf.w_[j] + trueF - predictedF
            end
        end

        # Debugging: should improve after each epoch
        n = num_correct_labels(crf, data, labels, N, tags)
        t = percent_correct_tags(crf, data, labels, N, tags)

        info("epoch $iter: $n / $N, percent correct tags: $t")

    end
end
