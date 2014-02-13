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
    correct_each_tag::Dict{Tag, Int}
    total_each_tag::Dict{Tag, Int}
end

function +(a::CRFMetrics, b::CRFMetrics)
    c = CRFMetrics(a.correct_tags + b.correct_tags,
                   a.total_tags + b.total_tags,
                   a.correct_sentences + b.correct_sentences,
                   a.total_sentences + b.total_sentences, deepcopy(a.correct_each_tag), deepcopy(a.total_each_tag))
    for (tag, count) in b.correct_each_tag
  	if haskey(c.correct_each_tag, tag)
            c.correct_each_tag[tag] += count
        else
            c.correct_each_tag[tag] = count
        end
    end
    for (tag, count) in b.total_each_tag
  	if haskey(c.total_each_tag, tag)
            c.total_each_tag[tag] += count
        else
            c.total_each_tag[tag] = count
        end
    end
    return c
end

function +{T <: Number}(a::(T, T), b::(T, T))
    return (a[1] + b[1], a[2] + b[2])
end

function percent_correct_tags(crf::ConditionalRandomFieldClassifier, data::Sentences, labels::Labels)
    # Calculate the number of sentences the CRF correctly labels

    # (DEBUG flattening)
    #metrics = CRFMetrics(0, 0, 0, 0, Dict{Tag, Int}(), Dict{Tag, Int}())
    #for i in 1:length(data) 
    metrics = @parallel (+) for i in 1:length(data) 
        correct_tags, correct_each_tag, total_each_tag = 0, Dict{Tag, Int}(), Dict{Tag, Int}()
        x, true_label = data[i], labels[i]
        label_length = length(true_label)

        #@assert length(x) == label_length "label lengths should be equal"

        predicted_label = predict(crf, x)
        for k = 1:label_length
            true_tag = true_label[k]
            if true_tag == predicted_label[k]
                correct_tags += 1

                # keep track of tag-level statistics
                if haskey(correct_each_tag, true_tag)
                    correct_each_tag[true_tag] += 1
                else
                    correct_each_tag[true_tag] = 1
                end
            end
            if haskey(total_each_tag, true_tag)
                total_each_tag[true_tag] += 1
            else
                total_each_tag[true_tag] = 1
            end
        end
        correct_sentences = booleanize(predicted_label == true_label) # 1 or 0
        CRFMetrics(correct_tags, label_length, correct_sentences, 1, correct_each_tag, total_each_tag)
    end
   
    info(metrics)
    #@assert length(data) == length(labels) "lengths must be equal"
    #@assert (metrics.total_tags == sum(values(metrics.total_each_tag))) "individual tag metrics should add up"
    #@assert (metrics.correct_tags == sum(values(metrics.correct_each_tag))) "total tags should be equal to the breakdown"

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

