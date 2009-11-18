Feature:
I want to parse a flat-file on my disk.

Background:
  Given simple data:
"""
AA x1
BB y1
CC z1
abcd
//
AA x1
BB y1
CC z1
abcd
//
AA x1
BB y1
CC z1
abcd
//
"""

Scenario: By default the separator is "//"
  Given the default rules
    And I define a parser which counts entry
    And I run the parser on simple data
  Then the result is "3"

  
