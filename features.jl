include("tags.jl")
include("featurelib.jl")

############################################################
# Our Standard Features
############################################################

function word_length{T <: String}(len::Int, i::Index, x::Vector{T})
  # Matches on specific word lengths
  return booleanize(length(x[i]) == len)
end

function is_word{T <: String}(word::T, i::Index, x::Vector{T})
  # Is a specific word at position i?
  return booleanize(x[i] == word)
end

function is_tag{T <: String}(tag::Tag, i::Index, x::Vector{T}, yt, yt_before)
  # Every possible tag at this position
  return booleanize(yt == tag)
end

function is_n_to_last_word(j::Index, i::Index, x::Vector{T})
    return (length(x) - i) == j
end

is_last_word_template = FeatureTemplate("is %s to last word", is_n_to_last_word, [0, 1, 2])
word_length_template = FeatureTemplate("word length is %s", word_length, [1, 2, 3, 4, 5, 6, 7, 8])
dictionary_template = FeatureTemplate("word is \"%s\"", is_word, UTF8String["Graham", "Bill"])
one_tag_template = FeatureTemplate("tag is %s", is_tag, all_tags)

# All of our features in one convenient object
our_a_templates = [dictionary_template, is_last_word_template, word_length_template]
our_b_templates = [one_tag_template]
our_templatized_features = TemplatizedFeatures(our_a_templates, our_b_templates)
our_features = build_features(our_templatized_features)

