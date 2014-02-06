include("util.jl")
include("tags.jl")

##########################################
# Features and Feature Templates class
##########################################

# Feature Templates generate a bunch of features
type FeatureTemplate
  f::Function # Accepts one of the args below as first argument
  args::Array
end

# Features object holds all the feature templates
type Features
  as::Array{FeatureTemplate}
  bs::Array{FeatureTemplate}
end

type FeatureFunction
  a::FeatureTemplate
  a_index::Index
  b::FeatureTemplate
  b_index::Index
end


##############################################################
# Number of features in a template or list of FeatureTemplates
##############################################################

function num_features(template::FeatureTemplate)
  return length(template.args)
end

function num_features(templates::Array{FeatureTemplate})
  f = 0
  for template in templates
    f += num_features(template)
  end
  return f
end

function num_features(features::Features)
  return num_features(features.as) * num_features(features.bs)
end

############################################################
# Our Features
############################################################

function is_word{T <: String}(word::T, i::Index, x::Array{T, 1})
  # Is a specific word at position i?
  return booleanize(x[i] == word)
end

dictionary_template = FeatureTemplate(is_word, ["Graham", "Bill"])

function is_tag{T <: String}(tag::Tag, i::Index, x::Array{T}, yt, yt_before)
  # Every possible tag at this position
  return booleanize(yt == tag)
end

one_tag_template = FeatureTemplate(is_tag, all_tags)

# All of our features in one convenient object
our_features = Features([dictionary_template], [one_tag_template])

function evaluate_feature(feature::FeatureFunction, i::Index, x::Array{T}, yt, yt_before)
  a_arg = feature.a.args[feature.a_index]
  b_arg = feature.b.args[feature.b_index]
  a = feature.a.f(a_arg, i, x, yt, yt_before)
  b = feature.b.f(b_arg, i, x, yt, yt_before)
  return (a * b)
end


