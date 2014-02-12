using Base.Test
include("collins_perceptron.jl")
include("features.jl")
include("read_data.jl")

crf = CollinsPerceptronCRF(all_tags, our_features, 1)
println("num features: ", num_features(crf))

fit!(crf, train_sentences, train_labels, test_data=test_sentences[1:100], test_labels=test_labels[1:100])

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"], all_tags) == [SPACE, SPACE, SPACE, PERIOD]

