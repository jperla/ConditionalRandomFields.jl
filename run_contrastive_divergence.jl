using Base.Test
require("contrastive_divergence.jl")
require("features.jl")
require("read_data.jl")

crf = ContrastiveDivergenceCRF(all_tags, our_features, 3)
println("num features: ", num_features(crf))

fit!(crf, train_sentences[1:300], train_labels[1:300], test_data=test_sentences[1:100], test_labels=test_labels[1:100])



metrics = percent_correct_tags(crf, test_data, test_labels)
info("**FINAL RESULTS** $metrics")



top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"]) == [SPACE, SPACE, SPACE, PERIOD]

