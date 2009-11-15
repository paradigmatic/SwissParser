require 'lib/swissparser'
require 'spec/expectations'
require 'spec/mocks'


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

When /^I run the simple parser on data$/ do
  @result = @simple_parser.parse(@data)
end


When /^I run the extended parser on data$/ do
  @result = @ext_parser.parse(@data)
end

When /^I run the extended parser on data with param "([^\"]*)" = "([^\"]*)"$/ do |key, val|
   @result = @ext_parser.parse(@data, key => val)
end


When /^I run it on file "([^\"]*)"$/ do |filename|
  File.stub!(:open).and_return(@data)
  @result = @simple_parser.parse_file( filename )
end


When /^I run it on a remote file "([^\"]*)"$/ do |arg1|
  OpenURI.stub!(:open).and_return(@data)
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


Then /^File\.open should be called with "([^\"]*)"$/ do |filename|
  File.should_receive(:open).with(filename,'w')
end

Then /^OpenUri\.open should be called with "([^\"]*)"$/ do |filename|
  OpenURI.should_receive(:open).with(filename)  
end

Then /^the simple parser should raise an error when parsing data$/ do
  lambda{@simple_parser.parse(@data)}.should raise_error
end
