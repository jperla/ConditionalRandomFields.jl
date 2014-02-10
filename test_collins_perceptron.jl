include("collins_perceptron.jl")
include("features.jl")
include("read_data.jl")

crf = CollinsPerceptronCRF(our_features, 10, zeros(Float64, 14))

fit!(crf, test_sentence, test_label, size(test_sentences, 1))

@test predict(crf, UTF8String["Bill", "Graham", "is", "dead"]) == [SPACE, SPACE, SPACE, PERIOD]