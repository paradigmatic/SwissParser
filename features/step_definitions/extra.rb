require 'lib/swissparser'
require 'spec/expectations'

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

When /^the before action sets @foo="([^\"]*)"$/ do |val|
   @ext_parser = @ext_parser.extend do 
    before { @foo=val; [] }
  end 
end

When /^the after action returns @foo$/ do
  @ext_parser = @ext_parser.extend do 
    after { @foo }
  end 
end

When /^set with\("([^\"]*)"\) to skip the entry$/ do |key|
  
end




When /^I set it to skip entries with\("([^\"]*)"\) containing "([^\"]*)"$/ do |key, val|
 @ext_parser = @ext_parser.extend do 
    rules do
      with(key) do |c,e|
        if c.include?(val)
          skip_entry!
        end
      end
    end
  end
end
