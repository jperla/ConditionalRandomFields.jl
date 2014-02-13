require("featurelib.jl")

typealias Sentences Array{Array{UTF8String, 1}, 1}
typealias Labels Array{Array{Tag, 1}, 1}

typealias Weight Float64 # weights for each of the features

abstract Classifier
abstract ConditionalRandomFieldClassifier <: Classifier

########################################################
# Fitting general CRFs with different prediction rules
########################################################

function fit!(crf::ConditionalRandomFieldClassifier, data::Sentences, labels::Labels, next_weights_function::Function; test_data::Sentences = [], test_labels::Labels = [])
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
            crf.w_ = next_weights_function(crf, x, true_label)

            if ((i % 5) == 1) && (length(test_data) > 0)
                t = percent_correct_tags(crf, test_data, test_labels)

                info("epoch $iter, i=$i: percent correct tags: $t")
                top_features(crf.features, crf.w_, n=20)
            end
        end
    end
end

##############################################
# Calculate the error
##############################################

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
    total_correct = @parallel (+) for i in 1:length(data) 
        correct_tags = 0
        x, true_label = data[i], labels[i]
        label_length = length(true_label)

        assert(length(x) == label_length)

        predicted_label = predict(crf, x)
        for k = 1:label_length
            if true_label[k] == predicted_label[k]
              correct_tags += 1
            end
        end
        correct_tags
    end
   
    assert(length(data) == length(labels))

    total_tags = 0
    for s in data
        total_tags += length(s) 
    end
    return total_correct / total_tags
end

##############################################
# Debugging the weights / features
##############################################

function top_features(features::Features, weights::Vector{Weight}; n::Int=10)
    top_weights = sort([(abs(w), w, j) for (j,w) in enumerate(weights)], rev=true)
    for i in 1:n
        _, w, feature_j = top_weights[i]
        @printf("%s: %s\n", w, show(features, feature_j))
    end
end

