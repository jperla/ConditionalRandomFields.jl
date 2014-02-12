using Base.Test
require("features.jl")

###############################################################
#   Test evaluate_feature
###############################################################


test_sentence = ["", "Bill", "Graham", "is", "dead"]
test_tags = Tag[START, SPACE, SPACE, SPACE, PERIOD]

test_features = build_features(TemplatizedFeatures([dictionary_template], [one_tag_template]))

#
#  Bill = Start
#

