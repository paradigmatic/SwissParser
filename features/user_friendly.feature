Feature: User Friendly
  SwissParser is nice to use.

  Background:
   Given input data 
     """
     XX a1
     YY b1
     c1
     //
     XX a1
     YY b2
     c2
     //
     """
 
  Scenario: Helper Method
    Given a simple parser
    When I extend it
      And I define 'foo' helper
      And I call 'foo' helper in after action
      And I run the extended parser on data
    Then the result should be "'foo'"

  Scenario: Parsing Parameters
    Given a simple parser
    When I extend it
      And I return param "foo" in after action
      And I run the extended parser on data with param "foo" = "bar"
    Then the result should be "'bar'"