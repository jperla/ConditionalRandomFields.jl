# Use Index instead of specific numbers throughout the code
typealias Index Integer
typealias Tag Int64

# Convert a boolean to a 0/1 value for use in math
function booleanize(b::Bool)
  if b
    return 1.0
  else
    return 0.0
  end
end