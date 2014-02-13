using Base.Test
require("contrastive_divergence.jl")
require("features.jl")
require("read_data.jl")

crf = ContrastiveDivergenceCRF(all_tags, some_features, 0.1, 1)
println("num features: ", num_features(crf))

fit!(crf, train_sentences[1:30], train_labels[1:30], test_data=test_sentences[1:30], test_labels=test_labels[1:30])

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"]) == [SPACE, SPACE, SPACE, PERIOD]

