include("featurelib.jl")

typealias Weight Float64 # weights for each of the features

abstract Classifier
abstract ConditionalRandomFieldClassifier <: Classifier

function num_correct_labels(crf::ConditionalRandomFieldClassifier, data::Function, labels::Function, N::Int)
    # Calculate the number of sentences the CRF correctly labels
    n = 0
    for i in 1:N
        x, true_label = data(i), labels(i)
        predicted_label = predict(crf, x)
        if true_label == predicted_label
            n += 1
        end
    end
    return n
end

function top_features(features::Features, weights::Vector{Weight}; n::Int=10)
    top_weights = sort([(abs(w), w,j) for (j,w) in enumerate(weights)], rev=true)
    for i in 1:n
        _, w, feature_j = top_weights[i]
        @printf("%s: %s\n", w, show(features, feature_j))
    end
end
