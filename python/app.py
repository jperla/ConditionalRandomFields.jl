
import settings
from features import build_features, FeatureFunction
from templates import *



a_templates = [WordLengthTemplate]
b_templates = [TagSequenceTemplate]

(a_features, b_features) = build_features(a_templates, b_templates)


print "a_features: ", a_features
print "b_features: ", b_features
#feature_function = FeatureFunction(a_features, b_features)


feature_function = FeatureFunction(a_features, b_features)



for i in xrange(feature_function.cardinality()):
    print feature_function.evaluate(i, ["hello"], ["yooo"], 0)
