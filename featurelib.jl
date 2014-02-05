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
  a::Function
  a_index::Index
  b::Function
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

function is_word(word::ASCIIString, i::Index, x::Array{ASCIIString, 1})
  # Converts ascii arguments to explicit UTF8
  return is_word(utf8(word), i, utf8(x))
end

function is_word(word::UTF8String, i::Index, x::Array{UTF8String, 1})
  # Is a specific word at position i?
  return booleanize(x[i] == word)
end

dictionary_template = FeatureTemplate(is_word, ["Graham", "Bill"])

function is_tag(tag::Tag, i::Index, x::Array{ASCIIString}, yt, yt_before)
  return is_tag(tag, i, utf8(x), yt, yt_before)
end

function is_tag(tag::Tag, i::Index, x::Array{UTF8String}, yt, yt_before)
  # Every possible tag at this position
  return booleanize(yt == tag)
end

one_tag_template = FeatureTemplate(is_tag, all_tags)

# All of our features in one convenient object
our_features = Features([dictionary_template], [one_tag_template])



