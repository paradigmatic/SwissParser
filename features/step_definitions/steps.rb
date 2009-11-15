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

When /^I replace with_text_after\("([^\"]*)"\) to return always '([^\']*)'$/ do |key,out|
  text_key = "txt-#{key}"
  @ext_parser = @ext_parser.extend do 
    rules do
      with_text_after( key ) {|c,e| e[text_key] = out }
    end
  end
end

When /^I set the separator to '([^\']*)'$/ do |sep|
  @ext_parser = @ext_parser.extend do 
    rules do
      set_separator( sep )
    end
  end
end

When /^I define '([^\']*)' helper$/ do |name|
  @ext_parser = @ext_parser.extend do 
    helper(name.to_sym) do
      name
    end
  end
end

When /^I call '([^\']*)' helper in after action$/ do |name|
  l = eval("lambda { |x| #{name} }")
  @ext_parser = @ext_parser.extend do 
    after(&l)
  end
end

When /^I return param "([^\"]*)" in after action$/ do |name|
  l = eval("lambda { |x| param(#{name}) }")
  @ext_parser = @ext_parser.extend do 
    after(&l)
  end

end

When /^I call parse with param "([^\"]*)" equal to "([^\"]*)"$/ do |key, val|
  @result = @ext_parser.parse(@data, key => val)
end

Then /^the result should be "([^\"]*)"$/ do |val|
  @result.should == val
end


Then /^the parser should return '([^\']*)'$/ do |val|
  @ext_parser.parse( @data ).should == val
end

Then /^the parser should return '(\d*)' entries$/ do |num|
  @ext_parser.parse( @data  ).size.should == num.to_i
end

Then /^the extended parser should parse it as the original one$/ do
  @simple_parser.parse( @data ).should == @ext_parser.parse( @data )
end


Then /^the parser should return "([^\"]*)"$/ do |ruby_exp|
  result = eval(ruby_exp)
  @ext_parser.parse( @data ).should == result
end
