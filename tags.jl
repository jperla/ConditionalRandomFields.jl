typealias Tag Int64

const START = 0
const SPACE = 1
const COMMA = 2
const PERIOD = 3
const QUESTION_MARK = 4
const EXCLAMATION_POINT = 5
const COLON = 6

global all_tags = [START, SPACE, COMMA, PERIOD, QUESTION_MARK, EXCLAMATION_POINT, COLON]

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
