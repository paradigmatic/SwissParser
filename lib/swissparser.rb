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

require 'open-uri'
require 'swissparser/parsing_context'
require 'swissparser/parsing_rules'

module Swiss

  VERSION = "1.0.0"

  class Rules
    
    DEFAULT_SEPARATOR = "//"

    attr_reader :separator

    def initialize( separator=nil )
      if separator.nil?
        @separator = DEFAULT_SEPARATOR
      else
        @separator = separator
      end
    end

    def define_parser( &body )
      Parser.new( self, body )
    end
    
    def refine( &proc )
      new_rules = Rules.new( @separator )
      new_rules.instance_eval(&proc)
      new_rules
    end

    private


    def set_separator( str )
      @separator = str
    end

  end
  
  class Parser

    def initialize( rules, body )
      @rules = rules
      @body = body
    end

    def parse( input )
      entries = Entries.new( @rules, input )
      @body.call( entries )
    end

  end

  class Entries

    def initialize( rules, input )
      @rules = rules
      @input = input
    end

    def size
      unless @size
        size = 0
        @input.each_line do |line|
          if separator?( line )
            size += 1
          end
        end
        @size = size
      end
      @size
    end
     
    private

    def separator?( line )
      line.strip == @rules.separator
    end
   
  end


  DefaultRules = Rules.new

end
