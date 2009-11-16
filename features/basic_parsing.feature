Feature: Basic Parsing
  I can parse from different sources

  Background:
   Given input data 
     """
     XX a1
     YY b1
     c1
     //
     XX a2
     YY b2
     c2
     //
     """
 
  Scenario: Parsing from string
    Given a simple parser
    When I run the simple parser on data
    Then the result should be "[{'XX'=>'a1','YY'=>'b1'},{'XX'=>'a2','YY'=>'b2'}]"

  Scenario: Parsing from file
    Given a simple parser
    When I run it on file "input.txt"
    Then File.open should be called with "input.txt"
 
  Scenario: Parsing from URI
    Given a simple parser
    When I run it on a remote file "http://www.example.com/input.txt"
    Then OpenUri.open should be called with "http://www.example.com/input.txt"