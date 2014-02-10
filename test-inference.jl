using Base.Test
include("features.jl")
include("inference.jl")


test_sentence = ["Bill", "Graham", "is", "dead"]
test_tags = [START, SPACE, SPACE, SPACE, PERIOD]
test_features = build_features(TemplatizedFeatures([dictionary_template], [one_tag_template]))
weights = ones(num_features(test_features))


####################################################################################
#  Test g_function
####################################################################################

#g1 = g_function(weights, test_features, )




####################################################################################
# test_viterbi
####################################################################################


