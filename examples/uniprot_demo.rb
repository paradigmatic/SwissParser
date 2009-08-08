#!/usr/bin/ruby -w

require 'yaml'
require 'swiss_parser.rb'

class Protein

  attr_accessor :id, :size, :species, :taxonomy, :sequence

  def initialize
    @taxonomy = []
    @sequence = ""
  end

end


uniprot_parser = Swiss::Parser.define do

  new_entry do
    Protein.new
  end

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
    seq = content.strip.gsub(" ","")
    protein.sequence += seq
  end

end


if $0 == __FILE__

  filename = ARGV.shift

  entries = uniprot_parser.parse_file( filename )

  puts entries.size

  entries.each do |e|
    puts e.to_yaml
  end

end
