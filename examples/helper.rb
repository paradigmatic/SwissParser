#!/usr/bin/ruby -w
 
require 'yaml'
require 'swissparser'

 
module HelperTest
 
  Rules = Swiss::DefaultRules.refine do

    helpers do
      def bar( text )
        "BAR: #{text}"
      end
    end


    # Parse the uniprot id
    with("ID") do |content|
      @foo = bar(content)
    end
    
  end

  Parser = Swiss::Parser.new( Rules ) do |entries|
    results = []
    entries.each do |e|
      results << e.foo
    end
    results
  end
  
end
  
  
if $0 == __FILE__

  puts Swiss::VERSION
    
  filename = ARGV.shift
 
  res = HelperTest::Parser.parse_file( filename ) 

  puts res.join(", ")

end
