require 'lib/swissparser'
require 'spec/expectations'

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

When /^I return "([^\"]*)" in new entry$/ do |value|
  @ext_parser = @ext_parser.extend do
    new_entry { value }
  end
end

When /^I replace the container with a counter$/ do
  class Counter
    def initialize
      @n = 0
    end
    def <<(i)
      @n += 1
    end
    def count
      @n
    end
  end
  @ext_parser = @ext_parser.extend do
    before { Counter.new }
    after {|c| c.count }
  end 
end

When /^entry finalize always returns "([^\"]*)"$/ do |val|
   @ext_parser = @ext_parser.extend do
    finish_entry {|e,c| c << val }
  end 
end



