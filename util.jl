# Use Index instead of specific numbers throughout the code
typealias Index Int
typealias Tag Int64

function booleanize(b::Bool)
    # Convert a boolean to a 0/1 value for use in math
    if b
      return 1.0
    else
      return 0.0
    end
end

function div_rem(a::Int, b::Int)
    # Divides a by b and returns a 2-tuple of the integer
    # part and the remainder
    r = (a % b)
    d = div(a, b)
    return d, r
end

function show(a::ASCIIString)
    # This should maybe be in 
    return a
end
