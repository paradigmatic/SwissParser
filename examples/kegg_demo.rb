require 'swiss_parser.rb'
require 'yaml'

class Enzyme
 
  attr_accessor :id, :genes
  
  def initialize()
    @genes = []
  end

  def is_human?()
    @genes.size > 0
  end


end


def enzyme_parser()

  human = "HSA"

  parser = Swiss::Parser.new
  
  parser.separator = "///"
  
  parser.new_entry do
    { :enzyme => Enzyme.new }
  end
  
  parser.with("ENTRY") do |content,entry|
    content =~ /((\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-))/
    entry[:enzyme].id = $1
  end

  def parse_gene_ids( string, enzyme )
    string.split(" ").each do |item|
      if item =~ /(\d+)\(\w+\)/
       enzyme.genes << $1
      end
    end
  end


  parser.with("GENES") do |content,entry|
    content =~ /^([A-Z]+): (.*)/  
    org,genes = $1,$2
    entry[:last_organism] = org
    if org == human
      parse_gene_ids( genes, entry[:enzyme] )
    end
  end

  parser.with_text do |content,entry,last_key|
    if last_key = "GENES"
      if content =~ /([A-Z]+): (.*)/
        org,genes = $1,$2
        entry[:last_organism] = org
        if org == human
           parse_gene_ids( genes, entry[:enzyme] )
        end
      elsif entry[:last_organism] == human
        parse_gene_ids( content, entry[:enzyme] )
      end      
    end
  end
  parser
  
end

if $0 == __FILE__

  filename = ARGV.shift

  entries = enzyme_parser.parse_file( filename )

  enzymes = entries.inject([]) do |ary,entry|
    if entry[:enzyme].is_human?
      ary << entry[:enzyme]
    end
    ary
  end

  enzymes.each do |e|
    puts e.to_yaml
  end

end


