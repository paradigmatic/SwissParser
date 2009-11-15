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

When /^I replace with\("([^\"]*)"\) to return always '([^\']*)'$/ do |key,out|
   @ext_parser = @ext_parser.extend do
    rules do
      with( key ) {|c,e| e[key] = out }
    end
  end
end

When /^I replace with\("([^\"]*)"\) to do nothing$/ do |key|
    @ext_parser = @ext_parser.extend do 
    rules do
      with( key ) {|c,e| }
    end
  end
end

Then /^the extended parser should parse it as the original one$/ do
  @simple_parser.parse( @data ).should == @ext_parser.parse( @data )
end


Then /^the parser should return "([^\"]*)"$/ do |ruby_exp|
  result = eval(ruby_exp)
  @ext_parser.parse( @data ).should == result
end
