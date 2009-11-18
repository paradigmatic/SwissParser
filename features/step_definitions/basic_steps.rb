require 'swissparser'
require 'spec/expectations'

Given /^simple data:$/ do |string|
  @data = string
end

Given /^the default rules$/ do
  @rules = Swiss::DefaultRules
end

Given /^I define a parser which counts entry$/ do
  @parser = @rules.define_parser do |entries|
    entries.size 
  end
end

Given /^I run the parser on simple data$/ do
  @result = @parser.parse( @data )
end

Then /^the result is "([^\"]*)"$/ do |expected|
  @result.to_s.should == expected
end
