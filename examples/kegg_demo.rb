require 'swissparser.rb'
require 'yaml'
 
class Enzyme
 
  attr_accessor :id, :genes
  
end

module Kegg
 
  Parser = Swiss::Rules.define do
    
    helpers do
      def parse_gene_ids(string)
        string.split(" ").each do |item|
          if item =~ /(\d+)\(\w+\)/
            unless @genes
              @genes = []
            end
            @genes << $1
          end
        end
      end
    end

    human = "HSA"
  
    set_separator( "///" )
    
    with("ENTRY") do |content|
      content =~ /((\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-))/
      @id = $1
    end
    
    with("GENES") do |content|
      content =~ /^([A-Z]+): (.*)/
      org,genes = $1,$2
      @last_organism = org
      if org == human
        parse_gene_ids( genes )
      end
    end
    
    with_text_after("GENES") do |content|
      if content =~ /([A-Z]+): (.*)/
        org,genes = $1,$2
        @last_organism = org
        if org == human
          parse_gene_ids( genes )
        end
      elsif @last_organism == human
        parse_gene_ids( content )
      end
    end
  end.make_parser do |entries|
    results = []
    entries.each do |entry|
      e = Enzyme.new
      e.id = entry.id
      e.genes = entry.genes
      results << e
    end
    results
  end
end

  
if $0 == __FILE__
    
  filename = ARGV.shift
 
  enzymes = Kegg::Parser.parse_file( filename ) 

  enzymes.each do |e|
    puts e.to_yaml
  end
 
end

