
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


x = reshape(Float64[1:16], 4, 4)
@test best_last_tag(x) == 4

x2 = transpose(reshape(Float64[1,1,1,1,1,
                  2,2,2,2,2,
                  13,14,3,4,5], 5, 3))

@test best_last_tag(x2) == 2

test_tags = Tag[START, SPACE, COMMA, PERIOD]
tag_index = indices(test_tags)
ti(t::Tag) = convert(Int64, tag_index[t])
@vectorize_1arg Tag ti

start_index = tag_index[START]
space_index= tag_index[SPACE]
comma_index = tag_index[COMMA]
period_index = tag_index[PERIOD]

# prev = ti(transpose(reshape(Tag[
#                 START, START, START, START, 
#                 SPACE, SPACE, SPACE, SPACE, 
#                 SPACE, SPACE, SPACE, SPACE, 
#                 SPACE, SPACE, SPACE, SPACE], 4, 4)))
   
prev = transpose(reshape(Int64[
                start_index, start_index, start_index, start_index, 
                space_index, space_index, period_index, space_index, 
                space_index, comma_index, space_index, space_index, 
                space_index, space_index, space_index, space_index], 4, 4))
   
println(best_label(tag_index[PERIOD], prev, test_tags))             
@test best_label(tag_index[PERIOD], prev, test_tags) == [PERIOD, COMMA, SPACE, PERIOD]






