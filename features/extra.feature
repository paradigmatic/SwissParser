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

Scenario: Parsing options
  Given the default rules
    And I define a simple rule to return option "foo" with "BB"
    And I define a simple parser which returns an array
    And I set option "foo" = "bar"
    And I run the parser on sample data
  Then the result evals to "%w{ bar bar bar}"

Scenario: Parsing from file
  Given the default rules
    And I define a simple parser which returns an array
  When I run the parser on file "input.txt"
  Then File.open should be called with "input.txt"
 
Scenario: Parsing from URI
  Given the default rules
    And I define a simple parser which returns an array  
  When I run it on remote file "http://www.example.com/input.txt"
  Then OpenUri.open should be called with "http://www.example.com/input.txt"

Scenario: Helper Methods
  Given the default rules
    And I define a simple rule to return "bar" via helper with "BB"
    And I define a simple parser which returns an array
    And I run the parser on sample data
  Then the result evals to "%w{ bar bar bar}"

