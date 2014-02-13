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
                metrics = percent_correct_tags(crf, test_data, test_labels)

                info("epoch $iter, i=$i: percent correct tags: $(metrics.correct_tags / metrics.total_tags)")
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

type CRFMetrics
    correct_tags::Int
    total_tags::Int
    correct_sentences::Int
    total_sentences::Int
    correct_each_tag::Array{Int64}
    total_each_tag::Array{Int64}
end

function +(a::CRFMetrics, b::CRFMetrics)
    c = CRFMetrics(a.correct_tags + b.correct_tags,
                   a.total_tags + b.total_tags,
                   a.correct_sentences + b.correct_sentences,
                   a.total_sentences + b.total_sentences,
                   a.correct_each_tag + b.correct_each_tag, 
                   a.total_each_tag + b.total_each_tag)
    return c
end

function +{T <: Number}(a::(T, T), b::(T, T))
    return (a[1] + b[1], a[2] + b[2])
end

function percent_correct_tags(crf::ConditionalRandomFieldClassifier, data::Sentences, labels::Labels)
    # Calculate the number of sentences the CRF correctly labels

    m = length(crf.tags)
    tag_index = indices(crf.tags)

    # (DEBUG flattening)
    #metrics = CRFMetrics(0, 0, 0, 0, Int64[0 for i in 1:10], Int64[0 for i in 1:10])
    #for i in 1:length(data) 
    metrics = @parallel (+) for i in 1:length(data) 
        correct_tags, correct_each_tag, total_each_tag = 0, Tag[0 for i in 1:m], Tag[0 for i in 1:m]
        x, true_label = data[i], labels[i]
        label_length = length(true_label)

        #@assert length(x) == label_length "label lengths should be equal"

        predicted_label = predict(crf, x)
        for k = 1:label_length
            true_tag = true_label[k]
            if true_tag == predicted_label[k]
                correct_tags += 1

                # keep track of tag-level statistics
                correct_each_tag[tag_index[true_tag]] += 1
            end
	    total_each_tag[tag_index[true_tag]] += 1
        end
        correct_sentences = booleanize(predicted_label == true_label) # 1 or 0
        CRFMetrics(correct_tags, label_length, correct_sentences, 1, correct_each_tag, total_each_tag)
    end
   
    info(metrics)
    #@assert length(data) == length(labels) "lengths must be equal"
    #@assert (metrics.total_tags == sum(metrics.total_each_tag)) "individual tag metrics should add up"
    #@assert (metrics.correct_tags == sum(metrics.correct_each_tag)) "total tags should be equal to the breakdown"

    return metrics
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

