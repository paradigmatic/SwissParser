Feature:
I want to parse a flat-file on my disk.

Background:
  Given sample data:
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
    And I run the parser on sample data
  Then the result is "3"

Scenario: I can change the separator
  Given the default rules
    And I set the separator to "%%"
    And I define a parser which counts entry
    And sample data:
"""
//
jdjdj
//
%%
//
jjdhhd
//
%%
"""
    And I run the parser on sample data
  Then the result is "2"
