=begin
Copyright (C) 2009 Paradigmatic

This file is part of SwissParser.

SwissParser is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SwissParser is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SwissParser.  If not, see <http://www.gnu.org/licenses/>.
=end

#!/usr/bin/ruby -w

require 'yaml'
require 'swissparser.rb'

class Protein

  attr_accessor :id, :size, :species, :taxonomy, :sequence

  def initialize
    @taxonomy = []
    @sequence = ""
  end

end

module Uniprot

  Parser = Swiss::Parser.define do

    # Each entry must be stored in a Protein instance
    new_entry do
      Protein.new
    end
    
    rules do 
      
      # Parse the uniprot id
      with("ID") do |content,protein|
        content =~ /([A-Z]\w+)\D+(\d+)/
        protein.id = $1
        protein.size = $2.to_i
      end
      
      # Parse the organism
      with("OS") do |content,protein|
        content =~ /(\w+ \w+)/
        protein.species = $1
      end
      
      # Parse the complete taxonomy
      with("OC") do |content,protein|
        ary = content.gsub(".","").split("; ")
        protein.taxonomy += ary
      end
      
      # Parse the Sequence
      with_text_after("SQ") do |content,protein|
        seq = content.strip.gsub(" ","")
        protein.sequence += seq
      end
      
    end
    
  end
  
end
  
if $0 == __FILE__
    
  filename = ARGV.shift

  entries = Uniprot::Parser.parse_file( filename )

  entries.each do |e|
    puts e.to_yaml
  end

end
