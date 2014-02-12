using Base.Test
include("collins_perceptron.jl")
include("features.jl")
include("read_data.jl")

crf = CollinsPerceptronCRF(our_features, 1)
println("num features: ", num_features(crf))

N = size(test_sentences, 1)
N = 10000

fit!(crf, training_sentence, training_label, N, all_tags, test_data=test_sentence, test_labels=test_label, test_N=100)

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"], all_tags) == [SPACE, SPACE, SPACE, PERIOD]

