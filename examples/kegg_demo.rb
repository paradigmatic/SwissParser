require 'swiss_parser.rb'
require 'yaml'

class Enzyme
 
  attr_accessor :id, :genes
  
end


enzyme_parser = Swiss::Parser.define do
  
  
  new_entry do
    { :genes => [] }
  end
  
  rules do

    def parse_gene_ids( string, entry )
      string.split(" ").each do |item|
        if item =~ /(\d+)\(\w+\)/
          entry[:genes] << $1
        end
      end
    end
    
    human = "HSA"
  
    set_separator( "///" )
    
    with("ENTRY") do |content,entry|
      content =~ /((\d+|-)\.(\d+|-)\.(\d+|-)\.(\d+|-))/
      entry[:id] = $1
    end
    
    with("GENES") do |content,entry|
      content =~ /^([A-Z]+): (.*)/  
      org,genes = $1,$2
      entry[:last_organism] = org
      if org == human
        parse_gene_ids( genes, entry )
      end
    end
    
    with_text_after("GENES") do |content,entry|
      if content =~ /([A-Z]+): (.*)/
        org,genes = $1,$2
        entry[:last_organism] = org
        if org == human
          parse_gene_ids( genes, entry )
        end
      elsif entry[:last_organism] == human
        parse_gene_ids( content, entry )
      end      
    end

  end
  
  finish_entry do |entry,container|
    if entry[:genes].size > 0
      e = Enzyme.new
      e.id = entry[:id]
      e.genes = entry[:genes]
      container << entry
    end
  end
  
end


if $0 == __FILE__

  filename = ARGV.shift

  enzymes = enzyme_parser.parse_file( filename )

  enzymes.each do |e|
    puts e.to_yaml
  end

end


