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


uniprot_parser = Swiss::Parser.define do

  new_entry do
    puts param(:msg)
    Protein.new
  end

  rules do 

    with("ID") do |content,protein|
      content =~ /([A-Z]\w+)\D+(\d+)/
      protein.id = $1
      protein.size = $2.to_i
    end
    
    with("OS") do |content,protein|
      content =~ /(\w+ \w+)/
      protein.species = $1
    end
    
    with("OC") do |content,protein|
      ary = content.gsub(".","").split("; ")
      protein.taxonomy += ary
    end
    
    with_text_after("SQ") do |content,protein|
      puts param(:found_seq)
      seq = content.strip.gsub(" ","")
      protein.sequence += seq
    end

  end

end


if $0 == __FILE__

  filename = ARGV.shift

  entries = uniprot_parser.parse_file( filename, :msg => "Hello", :found_seq => "Youpie" )

  puts entries.size

  entries.each do |e|
    puts e.to_yaml
  end

end
