require 'spec/expectations'
require 'spec/mocks'

Given /^I define a simple rule to return option "([^\"]*)" with "([^\"]*)"$/ do |opt_key, key|
  @rules = @rules.refine do
    with( key ) do |content|
      @text = option( opt_key )
    end
  end
end

Given /^I set option "([^\"]*)" = "([^\"]*)"$/ do |key, val|
  if @opt.nil?
    @opt = {}
  end
  @opt[key] = val
end

Given /^I define a simple rule to return "bar" via helper with "([^\"]*)"$/ do |key|
    @rules = @rules.refine do
    helpers do
      def foo( )
        "bar"
      end
    end
    with( key ) do |content|
      @text = foo
    end

  end
end

Given /^I define and helper "foo" which returns "([^\"]*)"$/ do |value|
  @rules = @rules.refine do
    helpers do
      def foob( )
        value
      end
    end
  end
end

When /^I run the parser on file "([^\"]*)"$/ do |filename|
  File.stub!(:open).and_return(@data)
  if @opt
    @result = @parser.parse_file( filename, @opt )
  else
    @result = @parser.parse_file( filename )
  end
end


When /^I run it on remote file "([^\"]*)"$/ do |uri|
  OpenURI.stub!(:open_uri).and_return(@data)
  if @opt
    @result = @parser.parse_uri( uri, @opt )
  else
    @result = @parser.parse_uri( uri )
  end
end

Then /^File\.open should be called with "([^\"]*)"$/ do |filename|
  File.should_receive(:open).with(filename,'w')
end

Then /^OpenUri\.open should be called with "([^\"]*)"$/ do |uri|
  OpenURI.should_receive(:open).with(uri)  
end

