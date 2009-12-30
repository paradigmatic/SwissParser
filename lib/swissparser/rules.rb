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

module Swiss

  #Parser rule set.
  class Rules
    
    DEFAULT_SEPARATOR = "//"

    attr_reader :separator, :rules

    #Do not initialize it directly, but use Swiss::DefaultRules#refine.
    def initialize( separator=nil, rules={}, helpers=[] )
      if separator.nil?
        @separator = DEFAULT_SEPARATOR
      else
        @separator = separator
      end
      @rules = rules
      if @rules[:text].nil?
        @rules[:text] = {}
      end
      @helpers = helpers
    end

    # Extends an existing parser by allowing to redefine rules. Helper
    # methods can be redefined too.
    def refine( &proc )
      new_rules = Rules.new( @separator, copy( @rules ), copy( @helpers) )
      new_rules.instance_eval(&proc)
      new_rules
    end

    # Returns a array with all the helper method blocks
    def get_helpers
      @helpers
    end

    private

    # Defines how to parse a line starting with +key+. The +proc+
    # takes one argument: the rest of the line
    def with( key, &proc )
      @rules[key] = proc
    end

    def helpers( &proc )
      @helpers << proc
    end

    # Defines how to parse a line without key coming *after* a
    # specified key. The +proc+ takes one argument: the rest of the
    # line
    def with_text_after( key, &proc )
      @rules[:text][key] = proc
    end

    # Sets the entry separator line. Default: "//"
    def set_separator( str )
      @separator = str
    end

    def copy(object)
      case object
        when Hash
        hash = object
        new_h = {}
        hash.each { |k,v| new_h[k] = v }
        if hash[:text] 
          new_h[:text] = copy( hash[:text] )
        end
        new_h
        when Array
        ary = object
        new_ary = []
        ary.each { |e| new_ary << e }
        new_ary
      end

    end

  end

end
