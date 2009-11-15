Feature: Parser Extension
  I can extend existing parser
  And replace existing rules

  Scenario: Extension without redefinition
    Given a simple parser
      And input data
        """
        XX a
        YY b
        //
        XX c
        YY d
        //
        """
    When I extend it
    Then the extended parser should parse it as the original one

  Scenario: Default separator
    Given a simple parser
      And input data
        """
        XX a
        YY b
        //
        XX c
        YY d
        //
        """
    When I extend it
      And I replace with("XX") to return always 'foo'
      And I replace with("YY") to do nothing
    Then the parser should return "[{ 'XX' => 'foo'}, { 'XX' => 'foo'}]"   
 
