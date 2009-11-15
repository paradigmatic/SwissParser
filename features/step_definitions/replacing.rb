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
