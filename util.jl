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

function unique_words{T <: String}(sentences::Array{Array{T, 1}, 1})
    words = T[]
    for s in sentences
        prepend!(words, s)
    end
    unique_set = union!(Set(), words)
    return T[u for u in unique_set]
end

function show(a::ASCIIString)
    # Why do i need this? 
    # Otherwise, I get ERROR: no method show(ASCIIString)
    return a
end

function show(a::UTF8String)
    # Why do i need this? 
    # Otherwise, I get ERROR: no method show(ASCIIString)
    return a
end

function show(a::Index)
    return string(a)
end

function show(a::(Any, Any))
    return string(show(a[1]), " and ", show(a[2]))
end

function sample{T <: Number}(numerators::Array{T})
    # Accepts a few numerators of probabilities, and then chooses
    # randomly from the probabilities
    s = sum(numerators)
    value = (rand() * s)
    for i in 1:length(numerators)
        value -= numerators[i]
        if value <= 0.0
            return i
        end
    end
    return 0
end

################################################################
# Reduce method for turning sparse vectors into dense vector
# during parallelization (julia @parallelize)
#################################################################

function make_sparse_merge(J::Int)
    # Normal case, add the sparse part to the array
    function sparse_merge(z::Array{Float64}, a::(Int, Float64))
        z[a[1]] = a[2]
        z
    end

    # Merging two lists case
    function sparse_merge(z1::Array{Float64}, z2::Array{Float64})
        z1 + z2
    end

    # First case, merge two sparse updates by making a new array
    function sparse_merge(a::(Int, Float64), b::(Int, Float64))
        z = zeros(Float64, J)
        z[a[1]] = a[2]
        z[b[1]] = b[2]
        z
    end

    return sparse_merge
end

