include("featurelib.jl")

@test 0 == 1

require("test")

test_context("Testing test tests")
test_group("simple tests")

test_sentence = ["Bill", "Graham", "is", "dead"]

@test is_word("Bill", 0, test_sentence)
@test !is_word("Bill", 1, test_sentence)

@test !is_word("Graham", 0, test_sentence)
@test is_word("Graham", 1, test_sentence)
  
@testfails is_word("Graham", 0, test_sentence)
@test is_word("Graham", 0, test_sentence)

@test 0 == 1