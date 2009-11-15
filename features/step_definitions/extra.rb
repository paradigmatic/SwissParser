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
