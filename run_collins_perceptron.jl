using Base.Test
require("collins_perceptron.jl")
require("features.jl")
require("read_data.jl")

crf = CollinsPerceptronCRF(all_tags, our_features, 2)
println("num features: ", num_features(crf))

fit!(crf, train_sentences[1:200], train_labels[1:200], test_data=test_sentences[1:100], test_labels=test_labels[1:100])


metrics = percent_correct_tags(crf, test_data[1:200], test_labels[1:200])
info("**FINAL RESULTS** $metrics")

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"]) == [SPACE, SPACE, SPACE, PERIOD]

