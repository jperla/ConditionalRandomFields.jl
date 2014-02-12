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
    predicted_label = predict_label(classifier.w_, classifier.features, sentence, crf.tags)
    return predicted_label
end

function fit!(crf::CollinsPerceptronCRF, data::Sentences, labels::Labels; test_data::Sentences = [], test_labels::Labels = [])
    # Data and Labels are functions which take a single integer argument in (1,N)
    N = length(data)
    J = num_features(crf)
    crf.w_ = zeros(J) # re-initialize to 0 for every fit

    for iter in 1:crf.n_iter
        for i in 1:N
	    if (i % 10) == 1
                info("example $i")
            end
            x, true_label = data[i], labels[i]
            predicted_label = predict(crf, x)
	    if predicted_label != true_label
                for j in 1:J
                    predictedF = evaluate_feature(crf.features, j, x, predicted_label)
                    trueF = evaluate_feature(crf.features, j, x, true_label)
                    crf.w_[j] = crf.w_[j] + trueF - predictedF
                end
            end
            if ((i % 5) == 1) && (length(test_data) > 0)
                # Debugging: should improve after each epoch
                #n = num_correct_labels(crf, data, labels, N)
                t = percent_correct_tags(crf, test_data, test_labels)

                info("epoch $iter, i=$i: percent correct tags: $t")
                top_features(crf.features, crf.w_, n=10)
            end
        end
    end
end
