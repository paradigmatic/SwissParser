Feature:
SwissParsers comes with user friendly features.

Background:
  Given sample data:
"""
AA x1
BB y1
CC z1
abcd
//
AA x2
BB y2
CC z2
efgh
//
AA x3
BB y3
CC z3
ijkl
//
"""

Scenario: Parsing Parameters
  Given the default rules
    And I define a simple rule to return option "foo" with "BB"
    And I define a simple parser which returns an array
    And I set option "foo" = "bar"
    And I run the parser on sample data
  Then the result evals to "%w{ bar bar bar}"

#Scenario: Helper Methods
#  Given the default rules
#    And I define a simple rule to return helper "foo" with "BB"
#    And I define and helper "foo" which returns "bar"
#    And I define a simple parser which returns an array
#    And I run the parser on sample data
#  Then the result evals to "%w{ bar bar bar}"

