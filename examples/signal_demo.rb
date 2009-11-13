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

require 'swiss_parser.rb'
require 'yaml'

class Protein
  attr_accessor :name, :sequence, :size
end

parser = Swiss::Parser.define do

  new_entry do
    Protein.new
  end
  
  rules do

    set_separator '/'

    with('N') do |content,entry|
      entry.name = content
    end
    
    with('C') do |content,entry|
      entry.size = content.to_i
    end
    
    with('S') do |content,entry|
      entry.sequence = content
    end
    
  end
    
end


stat_parser = parser.extend do

  before do
    { :min => 1_000, :max => 0, :sum => 0, :n => 0 }
  end 

  finish_entry do |entry,h|
    if entry.size < h[:min]
      h[:min] = entry.size
    end
    if entry.size > h[:max]
      h[:max] = entry.size
    end
    h[:sum] += entry.size
    h[:n] += 1
  end

  after do |h|
    h[:average] = h[:sum].to_f / h[:n]
    h
  end
    
end


if $0 == __FILE__

  filename = ARGV.shift

  entries = parser.parse_file( filename )
  
  entries.each do |e|
    puts e.to_yaml
  end
  
  puts
  
  results = stat_parser.parse_file( filename )

  puts "Min: #{results[:min]}"
  puts "Max: #{results[:max]}"
  puts "Average: #{results[:average]}"
  puts "Size: #{results[:n]}"

end


