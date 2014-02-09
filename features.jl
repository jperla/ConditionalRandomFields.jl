include("tags.jl")
include("featurelib.jl")

############################################################
# Our Standard Features
############################################################

function word_length{T <: String}(len::Int, i::Index, x::Array{T, 1})
  # Matches on specific word lengths
  return booleanize(length(x[i]) == len)
end

function is_word{T <: String}(word::T, i::Index, x::Array{T, 1})
  # Is a specific word at position i?
  return booleanize(x[i] == word)
end

function is_tag{T <: String}(tag::Tag, i::Index, x::Array{T}, yt, yt_before)
  # Every possible tag at this position
  return booleanize(yt == tag)
end

word_length_template = FeatureTemplate(word_length, [1, 2, 3, 4, 5, 6, 7, 8])
dictionary_template = FeatureTemplate(is_word, ["Graham", "Bill"])
one_tag_template = FeatureTemplate(is_tag, all_tags)

# All of our features in one convenient object
our_a_templates = [dictionary_template]
our_b_templates = [one_tag_template]
our_templatized_features = TemplatizedFeatures(our_a_templates, our_b_templates)
our_features = build_features(our_templatized_features)

