require 'swissparser'
require 'spec/expectations'

Given /^sample data:$/ do |string|
  @data = string
end

Given /^the default rules$/ do
  @rules = Swiss::DefaultRules
end

Given /^I set the separator to "([^\"]*)"$/ do |sep|
  @rules = @rules.refine do
    set_separator( sep )
  end
end

Given /^I define a simple rule to extract "([^\"]*)"$/ do |key|
  @rules = @rules.refine do
    with( key ) do |content| 
      @text = content
    end
  end
end

Given /^I define a simple rule to extract text after "([^\"]*)"$/ do |key|
  @rules = @rules.refine do 
    with_text_after( key ) do |content|
      @text = "" if @text.nil?
      @text << content
    end
  end
end

Given /^I define a simple rule to add "([^\"]*)" to an array$/ do |key|
  @rules = @rules.refine do
    with( key ) do |content| 
      @text = [] if @text.nil?
      @text << content
    end
  end
end

Given /^I define a simple rule to return "([^\"]*)" with "([^\"]*)"$/ do |val, key|
   @rules = @rules.refine do
    with( key ) do |content| 
      @text = val
    end
  end
end



Given /^I define a parser which counts entry$/ do
  @parser = @rules.define_parser do |entries|
    entries.size 
  end
end

Given /^I define a simple parser which returns an array$/ do
  @parser = @rules.define_parser do |entries|
    result = []
    entries.each do |entry|
      result << entry.text
    end
    result
  end
end

Given /^I run the parser on sample data$/ do
  @result = if @opt.nil?
              @parser.parse( @data )
            else 
              @parser.parse( @data, @opt )
            end
end


Then /^the result evals to "([^\"]*)"$/ do |expected|
  obj = eval( expected )
  @result.should == obj
end

Then /^the result is "([^\"]*)"$/ do |expected|
  @result.to_s.should == expected
end
