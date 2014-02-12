using Base.Test
include("collins_perceptron.jl")
include("features.jl")
include("read_data.jl")

crf = CollinsPerceptronCRF(our_features, 5)
println("num features: ", num_features(crf))

N = size(test_sentences, 1)
N = 1000

fit!(crf, test_sentence, test_label, N, all_tags)

top_features(crf.features, crf.w_, n=20)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"], all_tags) == [SPACE, SPACE, SPACE, PERIOD]

