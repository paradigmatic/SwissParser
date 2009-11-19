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
require 'swissparser/rules'

module Swiss

  VERSION = "0.90.0"

  
  class Parser

    def initialize( rules, body )
      @rules = rules
      @body = body
    end

    def parse( input, opt={} )
      entries = Entries.new( @rules, input, opt )
      @body.call( entries )
    end

    def parse_file( filename, opt={} )
      File.open( filename, 'r' ) do |file|
        parse( file, opt )
      end
    end

    def parse_uri( uri, opt={} )
      open( uri ) do |file|
        parse( file, opt )
      end
    end

  end

  DefaultRules = Rules.new
  DefaultRules.freeze

end
