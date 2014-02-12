using Base.Test
require("read_data.jl")

@test length(truncate_empty_words_at_end(["This", "", ""])) == 1
@test length(truncate_empty_words_at_end(["This", "should", "be", "shorter", "", "", ""])) == 4

@test train_sentences[1] == ["Therefore", "your", "feedback", "is", "critical"]
@test test_sentences[1] == ["I", "am", "at", "work", "and", "I'm", "NOT", "bored"]

@test training_labels[1] == Tag[COMMA, SPACE, SPACE, SPACE, PERIOD]
@test test_labels[1] == Tag[SPACE, SPACE, SPACE, SPACE, SPACE, SPACE, SPACE, PERIOD]
