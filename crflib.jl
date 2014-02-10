abstract Classifier
abstract ConditionalRandomFieldClassifier <: Classifier

function num_correct_labels(crf::ConditionalRandomFieldClassifier, data::Function, labels::Function, N::Int)
    # Calculate the number of sentences the CRF correctly labels
    n = 0
    for i in 1:N
        x, true_label = data(i), labels(i)
        predicted_label = predict(crf, x)
        if true_label == predicted_label
            n += 1
        end
    end
    return n
end