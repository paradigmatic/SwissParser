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

  VERSION = "0.5.1"

  # This class defines parsing rules. Its methods
  # are accessible within the +rules+ section of
  # a parser definition.
  class ParsingRules
    
    attr_reader :separator, :actions
    
    # *Do* *not* create directly this class but access it
    # through a +rules+ section in a parser definition.
    def initialize
      @actions = { :text => {} }
    end
    
    # Sets the entry separator line. Default: "//"
    def set_separator(string)
      @separator = string
    end

    # Defines how to parse a line starting with +key+. The +proc+
    # takes two arguments:
    # * the rest of the line
    # * the entry object
    def with( key, &proc )
      @actions[key] = proc
    end

    # Defines how to parse a line without key coming *after*
    # a specified key. The +proc+ takes two arguments:
    # * the rest of the line
    # * the entry object
    def with_text_after( key, &proc )
      @actions[:text][key] = proc
    end
    
  end


  # Parser for a typical bioinformatic flat file.
  class Parser
    
    #Default entry separator
    DEFAULT_SEPARATOR = "//"

    #*Do* *not* *use* this method to instatiate a parser. Use rather
    #the +define+ class method.
    def initialize(*args)
      if args.size == 0
        @separator = DEFAULT_SEPARATOR
        @actions = {}
        @actions[:text] = {}
      elsif args.size == 6
        actions,separator,before,the_begin,the_end,after = *args
        @actions = actions.clone
        @actions[:text] = actions[:text].clone
        @separator = separator
        @before = before
        @end = the_end
        @begin = the_begin
        @after = after
      else
        raise "Wrong arg number, either 0 or 6."
      end
    end

    # Defines how to create the _entry_ _object_. The +proc+
    # takes a single argument which is a hash containing
    # parsing options. It must return a new _entry_ _object_.
    # Default:: creates an empty hash.
    def new_entry(&proc)
       @begin = proc
    end

    # Defines how to finalize an _entry_ _object_. The +proc+
    # takes three arguments:
    # * The entry object ready to be finalized
    # * The context object
    # * An hash containing parsing options. 
    # Default:: Adds the entry object to the context object using +<<+ method.
    def finish_entry(&proc)
      @end = proc
    end
    
    # Defines how to set the context before using the parser.
    # The +proc+ takes a single argument which is a hash containing
    # parsing options. It must return a _context_ object.
    # Default:: creates an empty array
    def before (&proc)
      @before = proc
    end

    # Defines how to finalize the whole parsing.
    # The +proc+ takes two arguments:
    # * The context object
    # * An hash containing parsing options. 
    # The value returned by the +proc+ is then returned by the parsing method.
    # Default:: just returns the context object.
    def after(&proc)
      @after = proc
    end

    # Defines parsing rules inside a parser definition. The ParsingRules
    # methods can then be called inside the proc.
    def rules(&proc)
      r = ParsingRules.new
      r.instance_eval(&proc)
      r.actions.each do |k,v|
        if k == :text
          next
        end
        @actions[k] = v
        r.actions[:text].each do |k,v|
          @actions[:text][k] = v
        end
        if r.separator
          @separator = r.separator
        end
      end
    end



    # Extends an existing parser by allowing to redefine rules. The
    # changes in the new parser simply replace the original defintions.
    # After extension, the new parser is independent of the original one,
    # i.e. a change to the original parser will not affect the derived one.
    def extend(&proc)
      clone = Parser.new( @actions, @separator, @before, @begin, @end, @after )
      clone.instance_eval( &proc )
      clone
    end
                    
    # Defines a new parser. 
    def self.define( &proc )
      PROTOTYPE.extend( &proc )
    end

    # Parses a file specified by +filename+. An optional hash
    # of arbitrary arguments (+params+) can be specified. It is
    # passed to the workflow methods blocks (+before+, +new_entry+, ...)
    # It returns the value specified in the +after+ block. By default, 
    # it returns an array containing _entry_ objects.
    def parse_file( filename, params={} )
      context = @before.call( params )
      File.open( filename, 'r' ) do |file|
        entry = @begin.call( params )
        file.each_line do |line|
          state = parse_line( line, entry )
          if state == :end
            @end.call( entry, context, params )
            entry = @begin.call( params )
          end
        end
      end
      @after.call( context, params )
    end

    private

    PROTOTYPE = Parser.new
    PROTOTYPE.instance_eval do
      before { |p| [] }
      new_entry { |p| {} }
      finish_entry {|e,c,p| c << e }
      after {|c,p| c }
    end

    
    def parse_line( line, holder )
      line.chomp!
      if line == @separator
        :end
      elsif line =~ /^(\S+)\s+(.*)$/
        key,value = $1,$2
        @last_key = key
        if @actions[key]
          @actions[key].call( value, holder )
        end
        :parsing
      else
        if @actions[:text][@last_key]
          @actions[:text][@last_key].call( line, holder )
        end
        :parsing
      end
    end
    
  end

end
