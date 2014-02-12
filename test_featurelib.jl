using Base.Test
include("features.jl")

###############################################################
#   Test evaluate_feature
###############################################################


test_features = build_features(TemplatizedFeatures([dictionary_template], [one_tag_template]))

#
#  Bill = Start
#
