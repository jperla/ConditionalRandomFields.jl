include("tags.jl")

training_sentences = readdlm("punctuationDataset/trainingSentences.txt", ' ');
training_labels = readdlm("punctuationDataset/trainingLabels.txt", ' ');

test_sentences = readdlm("punctuationDataset/testSentences.txt", ' ');
test_labels = readdlm("punctuationDataset/testLabels.txt", ' ');

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

function training_sentence(i::Int)
    # Returns the ith training sentence
    return truncate_empty_words_at_end(training_sentences[i,:])
end

function test_sentence(i)
    # Returns the ith test sentence
    return truncate_empty_words_at_end(test_sentences[i,:])
end

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

function training_label(i::Int)
  return convert_tags(truncate_empty_words_at_end(training_labels[i,:]))
end

function test_label(i::Int)
  return convert_tags(truncate_empty_words_at_end(test_labels[i,:]))
end