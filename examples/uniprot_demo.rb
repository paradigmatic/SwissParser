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


uniprot_parser = Swiss::Parser.define do |p|

  p.new_entry do
    Protein.new
  end

  p.with("ID") do |content,protein|
    content =~ /([A-Z]\w+)\D+(\d+)/
    protein.id = $1
    protein.size = $2.to_i
  end

  p.with("OS") do |content,protein|
    content =~ /(\w+ \w+)/
    protein.species = $1
  end

  p.with("OC") do |content,protein|
    ary = content.gsub(".","").split("; ")
    protein.taxonomy += ary
  end
 
  p.with_text_after("SQ") do |content,protein,last_key|
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
