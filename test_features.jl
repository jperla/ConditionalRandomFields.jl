using Base.Test
include("featurelib.jl")

test_sentence = ["Bill", "Graham", "is", "dead"]

# Test is_word feature function
@test is_word("Bill", 1, test_sentence) == 1
@test is_word("Bill", 2, test_sentence) == 0

@test is_word("Graham", 1, test_sentence) == 0
@test is_word("Graham", 2, test_sentence) == 1

# Test is_tag feature function
@test is_tag(SPACE, 1, test_sentence, SPACE, START) == 1
@test is_tag(SPACE, 2, test_sentence, SPACE, SPACE) == 1
@test is_tag(SPACE, 4, test_sentence, QUESTION_MARK, SPACE) == 0
@test is_tag(QUESTION_MARK, 4, test_sentence, QUESTION_MARK, SPACE) == 1

# Test Features and the counter
@test num_features(dictionary_template) == 2 # only bill and graham so far
@test num_features(one_tag_template) == 7 # space, start, stop, etc...
@test num_features(our_features) == 14 # 2 words * 7 tags