using Base.Test
include("read_data.jl")

@test length(truncate_empty_words_at_end(["This", "", ""])) == 1
@test length(truncate_empty_words_at_end(["This", "should", "be", "shorter", "", "", ""])) == 4

@test training_sentence(1) == ["Therefore", "your", "feedback", "is", "critical"]
@test test_sentence(1) == ["I", "am", "at", "work", "and", "I'm", "NOT", "bored"]

@test training_label(1) == [COMMA, SPACE, SPACE, SPACE, PERIOD]
@test test_label(1) == [SPACE, SPACE, SPACE, SPACE, SPACE, SPACE, SPACE, PERIOD]

@test training_label(1) == [2, 1, 1, 1, 3]
@test test_label(1) == [1, 1, 1, 1, 1, 1, 1, 3]
