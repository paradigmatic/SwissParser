module Swiss

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

    def each()
      #Fiber.new do
      entry = Entry.new
      last_key = nil
      @input.each_line do |line|
        line.chomp!
        if separator?( line )
          yield entry
          last_key = nil
          entry = Entry.new
        elsif line =~ /^(\S+)\s+(.*)$/
          key,content = $1,$2
          last_key = key
          if @rules.rules[key]
            entry.instance_exec( content, &@rules.rules[key] )
          end 
        else
          if @rules.rules[:text][last_key]
            entry.instance_exec(  line.chomp.strip, &@rules.rules[:text][last_key]) 
          end
        end
      end   
    end
     
    private

    def separator?( line )
      line.strip == @rules.separator
    end
   
  end


  class Entry


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
