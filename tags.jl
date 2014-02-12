include("taglib.jl")

SPACE = convert(Tag, 78)
COMMA = convert(Tag, 20)
PERIOD = convert(Tag, 39)
QUESTION_MARK = convert(Tag, 4)
EXCLAMATION_POINT = convert(Tag, 5)
COLON = convert(Tag, 6)

global all_tags = Tag[START, SPACE, COMMA, PERIOD, QUESTION_MARK, EXCLAMATION_POINT, COLON]

function indices(tags::Array{Tag})
    # Returns map Tag => index in tags array input
    vk = Dict()
    for i in 1:length(tags)
      vk[tags[i]] = i
    end
    return vk
end

function show(tag::Tag)
    if tag == START
         return "START"
    elseif tag == SPACE
         return "SPACE"
    elseif tag == COMMA
         return "COMMA"
    elseif tag == PERIOD
         return "PERIOD"
    elseif tag == QUESTION_MARK
         return "QUESTION_MARK"
    elseif tag == EXCLAMATION_POINT
         return "EXCLAMATION_POINT"
    elseif tag == COLON
         return "COLON"
    end
end
