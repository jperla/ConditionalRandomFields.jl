using Base.Test
require("collins_perceptron.jl")
require("features.jl")
require("read_data.jl")

crf = CollinsPerceptronCRF(our_features, 2)

N = size(test_sentences, 1)
N = 100
fit!(crf, test_sentence, test_label, N, all_tags)

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"], all_tags) == [SPACE, SPACE, SPACE, PERIOD]

top_features(crf.features, crf.w_, n=20)

