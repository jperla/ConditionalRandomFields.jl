include("tags.jl")

function booleanize(b::Bool)
  if b
    return 1
  else
    return 0
  end
end

##########################################
# Features and Features Templates class
##########################################

# Feature Templates generate a bunch of features
type FeatureTemplate
  f::Function # Accepts one of the args below as first argument
  args::Array
end

type Features
  as::Array{FeatureTemplate}
  bs::Array{FeatureTemplate}
end

type FeatureFunction
  a::Function
  a_arg
  b::Function
  b_arg
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
    f += length(template)
  end
  return f
end

function num_features(features::Features)
  return num_features(features.as) * num_features(features.bs)
end

##############################################################
# Our Features
##############################################################

function is_word(word::String, i::Int, x::Array{String})
  # Is a specific word at position i?
  return booleanize(x[i] == word)
end

template1 = FeatureTemplate(is_word, ["Graham", "Bill"])

function is_tag(i::Int, x::Array{String}, yt, ytminusone)
  # Every possible tag at this position
  return booleanize(yt == SPACE)
end

template2 = FeatureTemplate(is_tag, all_tags)

our_features = Features([template1], [template2])



