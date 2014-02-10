# Use Index instead of specific numbers throughout the code
typealias Index Int64

function booleanize(b::Bool)
    # Convert a boolean to a 0/1 value for use in math
    if b
      return 1.0
    else
      return 0.0
    end
end

function show(a::ASCIIString)
    # Why do i need this? 
    # Otherwise, I get ERROR: no method show(ASCIIString)
    return a
end

function show(a::Index)
    return string(a)
end