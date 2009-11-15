Feature: Politeness
  SwissParser is polite and reporst errors

Scenario: Missing
  Given input data 
    """
    XX a1
    YY b1
    c1
    //
    XX a2
    YY b2
    c2
    """
    And a simple parser
  Then the simple parser should raise an error when parsing data
