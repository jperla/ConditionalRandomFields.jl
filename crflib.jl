require("featurelib.jl")

typealias Sentences Array{Array{UTF8String, 1}, 1}
typealias Labels Array{Array{Tag, 1}, 1}

typealias Weight Float64 # weights for each of the features

abstract Classifier
abstract ConditionalRandomFieldClassifier <: Classifier

function num_correct_labels(crf::ConditionalRandomFieldClassifier, data::Sentences, labels::Labels)
    # Calculate the number of sentences the CRF correctly labels
    n = 0
    for i in 1:N
        x, true_label = data[i], labels[i]
        predicted_label = predict(crf, x)
        if true_label == predicted_label
            n += 1
        end
    end
    return n
end

function percent_correct_tags(crf::ConditionalRandomFieldClassifier, data::Sentences, labels::Labels)
    # Calculate the number of sentences the CRF correctly labels
    correct_tags = 0
    total_tags = 0
    for i in 1:length(data)
        x, true_label = data[i], labels[i]
        predicted_label = predict(crf, x)
        label_length = length(true_label)
        for k = 1:label_length
            if true_label[k] == predicted_label[k]
              correct_tags += 1
            end
            total_tags += 1
        end
    end
    return correct_tags / total_tags
end

function top_features(features::Features, weights::Vector{Weight}; n::Int=10)
    top_weights = sort([(abs(w), w, j) for (j,w) in enumerate(weights)], rev=true)
    for i in 1:n
        _, w, feature_j = top_weights[i]
        @printf("%s: %s\n", w, show(features, feature_j))
    end
end
