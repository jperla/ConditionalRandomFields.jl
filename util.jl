# Use Index instead of specific numbers throughout the code
typealias Index Integer
typealias Tag Int64

# Convert a boolean to a 0/1 value for use in math
function booleanize(b::Bool)
  if b
    return 1
  else
    return 0
  end
end


# Extend utf8() so that it can convert 1d arrays of strings too
import Base.utf8
function utf8(oldstring::Array{ASCIIString, 1})
  newstring = reinterpret(UTF8String, oldstring)
  return newstring
end