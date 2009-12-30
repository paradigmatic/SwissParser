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

  # Parser for a typical bioinformatic flat file, like
  # SwissProt/Uniprot, KEGG, etc.
  class Parser

    #Create a new parser from a set of rules.
    # The method needs a block taking a single parameter which
    # holds the parsed entries.
    def initialize( rules, &body )
      @rules = rules
      @body = body
    end

    # Parses any input that accepts the +each_line+ method. Works for
    # string, open files, etc. An optional hash of arbitrary arguments
    # (+opt+) can be specified. It is passed to the workflow methods
    # blocks (+before+, +new_entry+, ...) It executes the block
    # defined when creating the parser and returns its last expression
    # result.
    def parse( input, opt={} )
      entries = Entries.new( @rules, input, opt )
      @body.call( entries )
    end

    # Parses a file specified by +filename+. An optional hash of
    # arbitrary arguments (+opt+) can be specified. It is passed to
    # the workflow methods blocks (+before+, +new_entry+, ...) It
    # executes the block defined when creating the parser and returns
    # its last expression result.
    def parse_file( filename, opt={} )
      File.open( filename, 'r' ) do |file|
        parse( file, opt )
      end
    end

    # Parses a file specified by an +URI+. Both http and ftp are
    # supported. An optional hash of arbitrary arguments (+opt+) can
    # be specified. It is passed to the workflow methods blocks
    # (+before+, +new_entry+, ...) It executes the block defined when
    # creating the parser and returns its last expression result.
    def parse_uri( uri, opt={} )
      open( uri ) do |file|
        parse( file, opt )
      end
    end

  end

  DefaultRules = Rules.new
  DefaultRules.freeze

end
