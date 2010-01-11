#!/usr/bin/ruby -w
 
require 'yaml'
require 'swissparser'
 
class Protein
 
  attr_accessor :swiss_id, :size, :species, :taxonomy, :sequence
 
  def initialize
    @taxonomy = []
    @sequence = ""
  end
 
end
 
module Uniprot
 
  Rules = Swiss::Rules.define do
      
    # Parse the uniprot id
    with("ID") do |content|
      content =~ /([A-Z]\w+)\D+(\d+)/
      @swiss_id = $1
      @size = $2.to_i
    end
    
    # Parse the organism
    with("OS") do |content|
      content =~ /(\w+ \w+)/
      @species = $1
    end
    
    # Parse the complete taxonomy
    with("OC") do |content|
      ary = content.gsub(".","").split("; ")
      if @taxonomy.nil?
        @taxonomy = []
      end
      @taxonomy += ary
    end
    
    # Parse the Sequence
    with_text_after("SQ") do |content|
      seq = content.strip.gsub(" ","")
      if @seq.nil?
        @seq = ""
      end
      @seq += seq
    end
    
  end

  #With the rules defined above, creates a parser
  # which returns an array of Protein instances.
  Parser = Rules.make_parser do |entries|
    results = []
    entries.each do |e|
      p = Protein.new
      p.swiss_id = e.swiss_id
      p.species = e.species
      p.taxonomy = e.taxonomy
      p.sequence = e.seq
      p.size = e.size
      results << p
    end
    results
  end
  
end
  
  
if $0 == __FILE__

  puts Swiss::VERSION
    
  filename = ARGV.shift
 
  proteins = Uniprot::Parser.parse_file( filename ) 

  proteins.each do |e|
    puts e.to_yaml
  end
 
end
