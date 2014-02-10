include("util.jl")

##########################################
# Features and Feature Templates class
#
# A feature is generated as a pair (A,B)
# where the As and Bs are generated from
# feature templates. Multiply every pair
# possible of As and Bs.
##########################################

# Feature Templates generate a bunch of features
type FeatureTemplate
  description::String
  f::Function # Accepts one of the args below as first argument
  args::Vector
end

# Features object holds all the feature templates
type TemplatizedFeatures
  as::Vector{FeatureTemplate}
  bs::Vector{FeatureTemplate}
end

type IndexedFeatureTemplate
  template::FeatureTemplate
  index::Index
end

type Features
  as::Vector{IndexedFeatureTemplate}
  bs::Vector{IndexedFeatureTemplate}
end

# Indexed Feature Template and Features methods
function arg(t::IndexedFeatureTemplate)
  return t.template.args[t.index]
end

function ab(features::Features, feature_j::Index)
  # Returns 2-tuple of the first half of the feature (A)
  # and the second half (B)
  bi, ai = divrem(feature_j - 1, length(features.as))
  ai, bi = ai+1, bi+1
  at = features.as[ai]
  bt = features.bs[bi]
  return at, bt
end

# Evaluating features

function evaluate_feature{T <: String}(t::IndexedFeatureTemplate, i::Index, x::Vector{T})
  # Calculates the A() part of Feature_j
  return t.template.f(arg(t), i, x)
end

function evaluate_feature{T <: String}(t::IndexedFeatureTemplate, i::Index, x::Vector{T}, yt::Tag, yt_before::Tag)
  # Calculates the B() part of Feature_j
  return t.template.f(arg(t), i, x, yt, yt_before)
end

function evaluate_feature{T <: String}(features::Features, feature_j::Index, i::Index, x::Vector{T}, yt::Tag, yt_before::Tag)
  # Calculates Feature_j for an individual word in a sentence
  at, bt = ab(features, feature_j)
  a = evaluate_feature(at, i, x)
  b = evaluate_feature(bt, i, x, yt, yt_before)
  return (a * b)
end

function evaluate_feature{T <: String}(features::Features, feature_j::Index, x_no_start::Vector{T}, y_no_start::Vector{Tag})
    # Calculates Feature_j over a whole sentence
    x = vcat(T[""], x_no_start)
    y = vcat([START], y_no_start)
    assert(length(x) == length(y))
    sum = 0
    for i in 2:length(x)
        sum += evaluate_feature(features, feature_j, i, x, y[i], y[i-1])
    end
    return sum
end

# Build Features object from templates
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

##############################################################
# Number of features in a template or list of FeatureTemplates
##############################################################

function num_features(template::FeatureTemplate)
  return length(template.args)
end

function num_features(template::IndexedFeatureTemplate)
  return length(template.template)
end

function num_features(templates::Vector{FeatureTemplate})
  f = 0
  for template in templates
    f += num_features(template)
  end
  return f
end

function num_features(features::Features)
  return length(features.as) * length(features.bs)
end

##############################################################
# Descriptions of features for printing / debugging
##############################################################

function show(t::IndexedFeatureTemplate)
  return replace(t.template.description, "%s", show(arg(t)))
end

function show(features::Features, feature_j::Index)
  at, bt = ab(features, feature_j)
  return string(show(at), " and ", show(bt))
end

function print_features{T <: String}(sentence::Vector{T}, features::Features)
    for (i,w) in enumerate(sentence)
        tag_before, tag = test_tags[i], test_tags[i+1]
        word_features = Int[]
        for feature_j in 1:num_features(features)
            score = evaluate_feature(features, feature_j, i, test_sentence, tag, tag_before)
            if score > 0
                push!(word_features, feature_j)
            end
        end

        # now print out summary for each word in sentence
        @printf("%s:", w)
        for feature_j in word_features
            @printf(" (%s)", show(features, feature_j))
        end
        @printf("\n")
    end
end
