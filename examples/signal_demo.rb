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


=begin
parser = Swiss::Parser.define do

  before do 
    { :min => 1_000, :max => 0, :sum => 0, :entries => [] }
  end 

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

  finish_entry do |entry,h|
    if entry.size < h[:min]
      h[:min] = entry.size
    end
    if entry.size > h[:max]
      h[:max] = entry.size
    end
    h[:sum] += entry.size
    h[:entries] << entry
  end

  after do |h|
    h[:average] = h[:sum].to_f / h[:entries].size
    h
  end
    
end
=end

if $0 == __FILE__

  filename = ARGV.shift

  results = parser.parse_file( filename )
  
  puts results[0].to_yaml
  puts results.size

  #results.each do |r|
  #  puts r.to_yaml
  #end

  #puts "Min: #{results[:min]}"
  #puts "Max: #{results[:max]}"
  #puts "Average: #{results[:average]}"
  #puts "Size: #{results[:entries].size}"

end


