
##########################################################################################
#  Test the inference algorithm and helper methods
##########################################################################################

using Base.Test
include("inference.jl")


test_sentence = ["Bill", "Graham", "is", "dead"]
test_tags = Tag[START, SPACE, SPACE, SPACE, PERIOD]


dictionary_template = FeatureTemplate("word is \"%s\"", is_word, ["Graham", "Bill", "dead", "is"])
one_tag_template = FeatureTemplate("tag is %s", is_tag, all_tags)

test_features = build_features(TemplatizedFeatures([dictionary_template], [one_tag_template]))


# Test Features and the counter
@test num_features(dictionary_template) == 4 # only bill and graham so far
@test num_features(one_tag_template) == 7 # space, start, stop, etc...
@test num_features(test_features) == 28 # 4 words * 7 tags
@test evaluate_feature(test_features, 6, 1, test_sentence, SPACE, START) == 1.0





