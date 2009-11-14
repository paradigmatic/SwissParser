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

require 'swissparser'
require 'examples/tutorial_1'

class Protein

  attr_accessor :id, :size, :species, :taxonomy, :sequence

  def initialize
    @taxonomy = []
    @sequence = ""
  end

end

module Uniprot

  SpeciesParser = Uniprot::Parser.extend do

    before do 
      {}
    end

    finish_entry do |protein, container|
      if container[protein.species].nil?
        container[protein.species] = []
      end
      container[protein.species] << protein
    end

  end
  
end
  
if $0 == __FILE__
    
  filename = ARGV.shift

  result = Uniprot::SpeciesParser.parse_file( filename )

  result.each do |species, ary|
    puts "#{species} => #{ary.map{ |p| p.id }.join(', ')}"
  end

end
