include("util.jl")
include("tags.jl")

##########################################
# Features and Feature Templates class
##########################################

# Feature Templates generate a bunch of features
type FeatureTemplate
  f::Function # Accepts one of the args below as first argument
  args::Vector
end

# Features object holds all the feature templates
type TemplatizedFeatures
  as::Array{FeatureTemplate}
  bs::Array{FeatureTemplate}
end

type IndexedFeatureTemplate
  template::FeatureTemplate
  index::Index
end

type Features
  as::Array{IndexedFeatureTemplate}
  bs::Array{IndexedFeatureTemplate}
end

function j_to_ab(j::Int, num_a::Int, num_b::Int)
  a = j % num_a
  b = div(j, num_a)
  return a, b
end

function build_features(t::TemplatizedFeatures)
  a_features = IndexedFeatureTemplate[]
  b_features = IndexedFeatureTemplate[]
  for template in t.as
    for i = 1:num_features(template)
      push!(a_features, IndexedFeatureTemplate(template, i))
    end
  end 

  for template in t.bs
    for i = 1:num_features(template)
      push!(b_features, IndexedFeatureTemplate(template,i)) 
    end
  end 
  return Features(a_features, b_features)
end

# Evaluating features
function evaluate_feature{T <: String}(indexed_feature_template::IndexedFeatureTemplate, i::Index, x::Array{T}, yt, yt_before)
  template = indexed_feature_template.template
  template_index = indexed_feature_template.index
  return template.f(template.args[template_index], i, x, yt, yt_before)
end

function evaluate_feature{T <: String}(features::Features, feature_j::Index, i::Index, x::Array{T}, yt, yt_before)
  ai, bi = j_to_ab(feature_j)
  at = features.as[ai]
  bt = features.bs[bi]
  a = evaluate_feature(at, i, x, yt, yt_before)
  b = evaluate_feature(bt, i, x, yt, yt_before)
  return (a * b)
end


##############################################################
# Number of features in a template or list of FeatureTemplates
##############################################################

function num_features(template::FeatureTemplate)
  return length(template.args)
end

function num_features(template::IndexedFeatureTemplate)
  return length(template.template)
end

function num_features(templates::Array{FeatureTemplate})
  f = 0
  for template in templates
    f += num_features(template)
  end
  return f
end

function num_features(features::Features)
  return length(features.as) * length(features.bs)
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
our_a_templates = [dictionary_template]
our_b_templates = [one_tag_template]
our_templatized_features = TemplatizedFeatures(our_a_templates, our_b_templates)
our_features = build_features(our_templatized_features)

