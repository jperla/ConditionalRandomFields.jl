using Base.Test
include("util.jl")

test_sentence = ["Bill", "Graham", "is", "alive"]
utf8_sentence = [utf8("Bill"), utf8("Graham"), utf8("is"), utf8("alive")]

# Test booleanize() converter
@test booleanize(true) == 1.0
@test booleanize(false) == 0.0
