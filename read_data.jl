require("tags.jl")

function convert_tags{T <: String}(tag_words::Array{T})
    tags = Tag[]
    for tag in tag_words
        if tag == "START"
            push!(tags, START)
        elseif tag == "SPACE"
            push!(tags, SPACE)
        elseif tag == "COMMA"
            push!(tags, COMMA)
        elseif tag == "PERIOD"
            push!(tags, PERIOD)
        elseif tag == "QUESTION_MARK"
            push!(tags, QUESTION_MARK)
        elseif tag == "EXCLAMATION_POINT"
            push!(tags, EXCLAMATION_POINT)
        elseif tag == "COLON"
            push!(tags, COLON)
        end
    end
    return tags
end

function truncate_empty_words_at_end(array_of_words)
    # Sentences in 2d array have extraneous empty characters at end.
    truncated = UTF8String[]
    for word in array_of_words
        if length(word) > 0
            push!(truncated, word)
        else
            break
        end
    end
    return truncated
end

function sentences(s::Array{Any, 2})
    all_sentences = Array(Array{UTF8String, 1}, 0)
    for i in 1:(size(s, 1) - 1)
        t = truncate_empty_words_at_end(s[i,:])
        push!(all_sentences, t)
    end
    return all_sentences
end

function labels(s::Array{Any, 2})
    all_labels = Array(Array{Tag, 1}, 0)
    for i in 1:(size(s, 1) - 1)
        t = convert_tags(truncate_empty_words_at_end(s[i,:]))
        push!(all_labels, t)
    end
    return all_labels
end

train_sentences = sentences(readdlm("punctuationDataset/trainingSentences.txt", ' '))
test_sentences = sentences(readdlm("punctuationDataset/testSentences.txt", ' '))

train_labels = labels(readdlm("punctuationDataset/trainingLabels.txt", ' '))
test_labels = labels(readdlm("punctuationDataset/testLabels.txt", ' '))
