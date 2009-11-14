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

module Swiss

  VERSION = "0.8.1"

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

  # Methods of this class are accessible to rules and actions.
  # Methods defined in +helpers+ block are added to this class.
  class ParsingContext

    def initialize(parameters)
      @params = parameters
    end   

    # Retrieves a parsing parameter by key. Returns nil if 
    # there is no parameter with the provided key.
    def param( key ) 
      @params[key]
    end


    module InstanceExecHelper     #:nodoc:
    end 
    
    include InstanceExecHelper

    #Method instance_exec exists since version 1.9
    if RUBY_VERSION < "1.9"
      #Used to execute rules and action using the ParsingContext as context
      #Stolen from http://eigenclass.org/hiki/bounded+space+instance_exec
      def instance_exec(*args, &block)
        begin
          old_critical, Thread.critical = Thread.critical, true
          n = 0
          n += 1 while respond_to?(mname="__instance_exec#{n}")
          InstanceExecHelper.module_eval{ define_method(mname, &block) }
        ensure
          Thread.critical = old_critical
        end
        begin
          ret = send(mname, *args)
        ensure
          InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
        end
        ret
      end
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
        @helpers = {}
      elsif args.size == 7
        actions,separator,before,the_begin,the_end,after,helpers = *args
        @actions = actions.clone
        @actions[:text] = actions[:text].clone
        @separator = separator
        @before = before
        @end = the_end
        @begin = the_begin
        @after = after
        @helpers = helpers
      else
        raise "Wrong arg number, either 0 or 7."
      end
      @ctx = nil
    end

    # Defines how to create the _entry_ _object_. The +proc+
    # does not take arguments, but it must return a new 
    # _entry_ _object_.
    # Default:: creates an empty hash.
    def new_entry(&proc)
       @begin = proc
    end

    # Defines how to finalize an _entry_ _object_. The +proc+
    # takes two arguments:
    # * The entry object ready to be finalized
    # * The context object
    # Default:: Adds the entry object to the context object using +<<+ method.
    def finish_entry(&proc)
      @end = proc
    end
    
    # Defines how to set the context before using the parser.
    # The +proc+ does not take arguments. It must return a _context_ object.
    # Default:: creates an empty array
    def before (&proc)
      @before = proc
    end

    # Defines how to finalize the whole parsing.
    # The +proc+ takes a single argument:
    # * The context object
    # The value returned by the +proc+ is then returned by the parsing method.
    # Default:: just returns the context object.
    def after(&proc)
      @after = proc
    end

    # Define an helper method accessible to rules and actions.
    # This method tales two argument:
    # * A symbol which will be the method name
    # * A block which is the method implementation. The block can take parameters.
    # The helper method can then be called as a regular method.
    def helper(name, &proc)
      @helpers[name] = proc
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
      clone = Parser.new( @actions, @separator, @before, @begin, @end, @after, @helpers )
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
      File.open( filename, 'r' ) do |file|
        parse( file, params )
      end
    end

    # Parses a file specified by an +URI+. Both http and ftp are
    # supported. An optional hash of arbitrary arguments (+params+)
    # can be specified. It is passed to the workflow methods blocks
    # (+before+, +new_entry+, ...)  It returns the value specified in
    # the +after+ block. By default, it returns an array containing
    # _entry_ objects.
    def parse_URI( uri, params={} )
      open( uri ) do |file|
        parse( file, params )
      end
    end

    private
    
    def parse( file, params )
      @ctx = ParsingContext.new( params )
      helperModule = Module.new
      @helpers.each do |name, proc|
        helperModule.send( :define_method, name, proc )
      end
      @ctx.extend( helperModule )
      container = @ctx.instance_exec( &@before )
      entry = @ctx.instance_exec( &@begin )
      file.each_line do |line|
        state = parse_line( line, entry )
        if state == :end
          @ctx.instance_exec( entry, container, &@end )
          entry = @ctx.instance_exec( &@begin )
        end
      end
      @ctx.instance_exec( container, &@after )
    end

    PROTOTYPE = Parser.new
    PROTOTYPE.instance_eval do
      before { || [] }
      new_entry { || {} }
      finish_entry {|e,c| c << e }
      after {|c| c }
    end

    
    def parse_line( line, holder )
      line.chomp!
      if line == @separator
        :end
      elsif line =~ /^(\S+)\s+(.*)$/
        key,value = $1,$2
        @last_key = key
        if @actions[key]
          @ctx.instance_exec( value, holder, &@actions[key] )
        end
        :parsing
      else
        if @actions[:text][@last_key]
          @ctx.instance_exec( line, holder, &@actions[:text][@last_key] )
        end
        :parsing
      end
    end
    
  end

end
