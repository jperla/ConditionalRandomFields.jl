

function gibbs(weights::Array{Weight}, features::Features, x::Sentence, input_tags::Array{Tag})

  n = length(x)
  m = length(input_tags)

  #randomly assign initial label 
    label=Tag[]
  for i=1:m
    label[i] = input_tags[rand(1:m)]
  end


  temp_label = label
  # for eaach position pick best label[i] conditioned on other labels
  for i = 1:n
    best_score = 0
    for j=1:m
      temp_label[i] = input_tags[j]
      
      score(weights, features, x, temp_label, input_tags)
      
      if new_score > best_score
        best_score = new_score
        label[i] = input_tags[j]
      end
    end
    
  end

  return label

end


# return score 
function score(weights::Array{Weight}, features::Features, x::Sentence, label::Array{Tag}, input_tags)


  assert(length(weights) == num_features(features)
  score = 0
  J = num_features(features)
  for j = 1:J
    score += weights[j] * evaluate_feature(features, j, x, label)
  end

end



