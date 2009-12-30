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

  # Represent all the entries
  class Entries

    def initialize( rules, input, opt )
      @rules = rules
      @input = input
      @opt = opt
    end

    def size()
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

    def each() 
      entry = new_entry
      last_key = nil
      @input.each_line do |line|
        line.chomp!
        if separator?( line )
          yield entry
          last_key = nil
          entry = new_entry
        elsif line =~ /^(\S+)\s+(.*)$/
          key,content = $1,$2
          last_key = key
          if @rules.rules[key]
            entry.instance_exec( content, &@rules.rules[key] )
          end 
        else
          if @rules.rules[:text][last_key]
            entry.instance_exec(  
                                line.chomp.strip, 
                                &@rules.rules[:text][last_key]
                                ) 
          end
        end
      end   
    end
     
    private

    def new_entry()
      entry = Entry.new( @opt )
      @rules.get_helpers.each do |helper|
        entry.add_helpers( helper )
      end
      entry
    end

    def separator?( line )
      line.strip == @rules.separator
    end
   
  end

  # Parsed entry
  class Entry

    def initialize( opt )
      @opt__ = opt
    end

    def option(key)
      @opt__[key]
    end

    def add_helpers( block )
      instance_eval( &block )
    end

    def method_missing(name, *args, &block) 
      #TODO better fail
      fail if args.size > 0
      iv = "@#{name}".to_sym
      instance_variable_get( iv )
   end

    module InstanceExecHelper     #:nodoc:
    end 
    
    include InstanceExecHelper

    #Method instance_exec exists since version 1.9
    if RUBY_VERSION < "1.9"
      #Used to execuxte rules and action using the ParsingContext as context
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

end
