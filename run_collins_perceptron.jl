using Base.Test
require("collins_perceptron.jl")
require("features.jl")
require("read_data.jl")

crf = CollinsPerceptronCRF(all_tags, our_features, 5)
println("num features: ", num_features(crf))

fit!(crf, train_sentences[1:100], train_labels[1:100], test_data=test_sentences[1:150], test_labels=test_labels[1:150])

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"]) == [SPACE, SPACE, SPACE, PERIOD]

