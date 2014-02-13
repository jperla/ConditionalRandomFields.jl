using Base.Test
require("util.jl")

test_sentence = ["Bill", "Graham", "is", "alive"]
utf8_sentence = [utf8("Bill"), utf8("Graham"), utf8("is"), utf8("alive")]

# Test booleanize() converter
@test booleanize(true) == 1.0
@test booleanize(false) == 0.0

function count(s)
    counts = Int[0, 0, 0, 0]
    for s in samples
        counts[s] += 1
    end
    return counts
end

samples = [sample(Float64[3, 3, 3, 3]) for i in 1:100]
println(count(samples))

samples = [sample(Float64[4, 2, 8, 2]) for i in 1:16000]
println(count(samples))
