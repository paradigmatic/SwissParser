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

Given /^I define a simple rule to return helper "([^\"]*)" with "([^\"]*)"$/ do |helper, key|
    @rules = @rules.refine do
    with( key ) do |content|
      puts "I'm in calling method #{helper}"
      @text = send( helper)
    end
  end
end

Given /^I define and helper "foo" which returns "([^\"]*)"$/ do |value|
  @rules = @rules.refine do
    helpers do
      def foo( )
        value
      end
    end
  end
end
