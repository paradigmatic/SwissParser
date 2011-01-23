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

Scenario: I can define a simple 'with' rule
  Given the default rules
    And I define a simple rule to extract "BB"
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "%w{ y1 y2 y3}"

Scenario: I can define a simple 'with_text_after' rule
  Given the default rules
    And I define a simple rule to extract text after "CC"
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "%w{ abcd efgh ijkl }"


Scenario: I can define several rules
  Given the default rules
    And I define a simple rule to add "BB" to an array
    And I define a simple rule to add "CC" to an array
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "[ %w{y1 z1}, %w{y2 z2}, %w{y3 z3}]"

Scenario: I can redefine rules
  Given the default rules
    And I define a simple rule to extract "CC"
    And I define a simple rule to return "foo" with "CC"
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "%w{foo foo foo}"

Scenario: I can parse a lone key
  Given sample data:
"""
AA Foo
BB
CC Bar
//
"""
    And the default rules
    And I define a rule which adds the key to an array with "AA"
    And I define a rule which adds the key to an array with "BB"
    And I define a rule which adds the key to an array with "CC"
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "[%W{AA BB CC}]"

