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
require 'swissparser/entries'

module Swiss

  VERSION = "0.90.0"

  class Rules
    
    DEFAULT_SEPARATOR = "//"

    attr_reader :separator, :rules

    def initialize( separator=nil, rules={} )
      if separator.nil?
        @separator = DEFAULT_SEPARATOR
      else
        @separator = separator
      end
      @rules = rules
    end

    def define_parser( &body )
      Parser.new( self, body )
    end
    
    def refine( &proc )
      new_rules = Rules.new( @separator, @rules )
      new_rules.instance_eval(&proc)
      new_rules
    end

    private

    def with( key, &proc )
      @rules[key] = proc
    end

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

  DefaultRules = Rules.new

end
