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

  VERSION = "0.5.0"

  class ParsingRules
    
    attr_reader :separator, :actions
    
    def initialize
      @actions = { :text => {} }
    end
    
    def set_separator(string)
      @separator = string
    end

    def with( key, &proc )
      @actions[key] = proc
    end

    def with_text_after( key, &proc )
      @actions[:text][key] = proc
    end
    
  end

  class Parser
    
    DEFAULT_SEPARATOR = "//"


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

    def new_entry(&proc)
       @begin = proc
    end

    def finish_entry(&proc)
      @end = proc
    end

    def before (&proc)
      @before = proc
    end
    def after(&proc)
      @after = proc
    end

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

    PROTOTYPE = Parser.new
    PROTOTYPE.instance_eval do
      before { |p| [] }
      new_entry { |p| {} }
      finish_entry {|e,c,p| c << e }
      after {|c,p| c }
    end

    def extend(&proc)
      clone = Parser.new( @actions, @separator, @before, @begin, @end, @after )
      clone.instance_eval( &proc )
      clone
    end
                    
    def self.define( &proc )
      PROTOTYPE.extend( &proc )
    end

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
