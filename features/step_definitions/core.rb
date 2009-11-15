require 'lib/swissparser'
require 'spec/expectations'


Given /^a simple parser$/ do
  @simple_parser = Swiss::Parser.define do
    rules do
      with("XX") {|c,e| e["XX"] = c}
      with("YY") {|c,e| e["YY"] = c}
    end
  end
end

Given /^input data$/ do |string|
  @data = string
end

When /^I extend it$/ do
  @ext_parser = @simple_parser.extend {}
end

When /^I run the extended parser on data$/ do
  @result = @ext_parser.parse(@data)
end

When /^I run the extended parser on data with param "([^\"]*)" = "([^\"]*)"$/ do |key, val|
   @result = @ext_parser.parse(@data, key => val)
end


Then /^the extended parser should parse it as the original one$/ do
  @simple_parser.parse( @data ).should == @ext_parser.parse( @data )
end


Then /^the result should be "([^\"]*)"$/ do |ruby_exp|
  result = eval(ruby_exp)
  @result.should == result
end

Then /^the result should contain '([^\']*)' entries$/ do |n|
  @result.size.should == n.to_i
end

