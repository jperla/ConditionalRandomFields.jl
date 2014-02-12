require("tags.jl")
require("featurelib.jl")

############################################################
# Our Standard Features
############################################################

function word_length{T <: String}(len::Int, i::Index, x::Vector{T})
  # Matches on specific word lengths
  return booleanize(length(x[i]) == len)
end

function sentence_length{T <: String}(len::Int, i::Index, x::Vector{T})
  # Matches on specific word lengths
  return booleanize(length(x) == len)
end

function is_word{T <: String}(word::T, i::Index, x::Vector{T})
  # Is a specific word at position i?
  return booleanize(lowercase(x[i]) == lowercase(word))
end

function is_n_to_last_word{T <: String}(j::Int, i::Index, x::Vector{T})
    return (length(x) - i) == j
end

function first_word_is{T <: String}(word::T, i::Index, x::Vector{T})
    return (lowercase(x[1]) == word) 
end

function word_ends_with{T <: String}(suffix::T, i::Index, x::Vector{T})
    return (endswith(x[i], suffix))
end

function one{T <: String}(none, i::Index, x::Vector{T})
    return 1.0
end

function is_tag{T <: String}(tag::Tag, i::Index, x::Vector{T}, yt::Tag, yt_before::Tag)
  # Every possible tag at this position
  return booleanize(yt == tag)
end

function last_tag_is{T <: String}(tag::Tag, i::Index, x::Vector{T}, yt::Tag, yt_before::Tag)
  return boolianize(yt == tag && i == length(x))
end

function tags_are{T <: String}(tags::(Tag,Tag), i::Index, x::Vector{T}, yt::Tag, yt_before::Tag)
  # Every possible tag at this position
  return booleanize(yt == tags[1] && yt_before == tags[2])
end



dictionary = UTF8String["Graham", "Bill"]


last_tag_template = FeatureTemplate("last tag is %s", last_tag_is, all_tags)
sentence_length_template = FeatureTemplate("Sentence length is %s", sentence_length, [1:15])
is_last_word_template = FeatureTemplate("%s to last word", is_n_to_last_word, [0, 1, 2])
word_length_template = FeatureTemplate("word length is %s", word_length, [1, 2, 3, 4, 5, 6, 7, 8])
dictionary_template = FeatureTemplate("word is \"%s\"", is_word, dictionary)
first_word_is_template = FeatureTemplate("first word is %s", first_word_is, UTF8String["what", "who", "when", "where", "how", "can", "did", "are", "should", "could", "which", "if", "do", "will"])

word_ends_with_template = FeatureTemplate("word ends with %s", word_ends_with, UTF8String["ly", "ing"])
one_template = FeatureTemplate("one", one, [1])

one_tag_template = FeatureTemplate("tag is %s", is_tag, all_tags)

two_tags = Array((Tag,Tag), 0)
for t1 in all_tags
    for t2 in all_tags
        push!(two_tags, (t1, t2))
    end
end

two_tag_template = FeatureTemplate("tags are %s", tags_are, two_tags)

# All of our features in one convenient object
our_a_templates = [dictionary_template, is_last_word_template, word_ends_with_template, first_word_is_template, one_template]
our_b_templates = [one_tag_template, two_tag_template]
our_templatized_features = TemplatizedFeatures(our_a_templates, our_b_templates)
our_features = build_features(our_templatized_features)

# A small, useful subset of features
some_a_templates = [one_template, word_ends_with_template, is_last_word_template]
some_b_templates = [one_tag_template]
some_templatized_features = TemplatizedFeatures(some_a_templates, some_b_templates)
some_features = build_features(some_templatized_features)

