Feature: Parser Extension
  I can extend existing parser
  And replace existing rules

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
 
  Scenario: Extension without redefinition
    Given a simple parser
    When I extend it
    Then the extended parser should parse it as the original one

  Scenario: With replacing separator
    Given a simple parser
    When I extend it
      And I replace with("XX") to return always 'foo'
      And I replace with("YY") to do nothing
      And I run the extended parser on data
    Then the result should be "[{ 'XX' => 'foo'}, { 'XX' => 'foo'}]"   
 
  Scenario: Text after replacing
    Given a simple parser
    When I extend it
      And I replace with("XX") to do nothing
      And I replace with("YY") to return always 'bar'
      And I replace with_text_after("YY") to return always 'foo'
      And I run the extended parser on data
    Then the result should be "[{ 'YY' => 'bar', 'txt-YY' => 'foo'}, { 'YY' => 'bar', 'txt-YY' => 'foo'}]" 

  Scenario: 
    Given a simple parser
      And input data 
        """
        XX a1
        YY b1
        c1
        %
        XX a1
        YY b2
        c2
        %
        """
     When I extend it
       And I set the separator to '%'
       And I run the extended parser on data
     Then the result should contain '2' entries
