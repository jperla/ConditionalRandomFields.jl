
import settings


class Template:
    total_funcs = 0
    def __init__(self):
    	return

    @staticmethod
    def cardinality():
        return Template.total_funcs

    def evaluate():
        return ""


class TagSequenceTemplate(Template):

    total_funcs = len(settings.tags) ** 2
    def __init__(self, index):
        self.index = index

    @staticmethod
    def cardinality():
        return TagSequenceTemplate.total_funcs

    def evaluate(self, yt, ybefore, loc):
    	return 1



class WordLengthTemplate:
    total_funcs = 20

    def __init__(self, index):
        self.index = index

    @staticmethod
    def cardinality():
        return WordLengthTemplate.total_funcs

    def evaluate(self, x_sequence, i):
        return int(len(x_sequence[i]) == self.index )


