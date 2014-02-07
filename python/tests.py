from templates import *
import settings
from features import *



wtpl = WordLength_Template(5)

assert wtpl.evaluate(["hello"], 0) == 1
assert wtpl.evaluate(["hello", "hell"], 1) == 0
assert wtpl.evaluate(["hello", "hellos"], 1) == 0




a_templates = [WordLength_Template]
b_templates = [TagSequence_Template]

(a_features, b_features) = build_features(a_templates, b_templates)

feature_function = FeatureFunction(a_features, b_features)
for i in xrange(feature_function.cardinality()):
    print feature_function.evaluate(i, ["hello"], ["yooo"], 0)

