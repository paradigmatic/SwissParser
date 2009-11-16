module Swiss

  # Methods of this class are accessible to rules and actions.
  # Methods defined in +helpers+ block are added to this class.
  class ParsingContext

    def initialize(parameters)
      @params__ = parameters
      @skip__ = false
    end   

    # Retrieves a parsing parameter by key. Returns nil if 
    # there is no parameter with the provided key.
    def param( key ) 
      @params__[key]
    end

    def skip_entry!()
      @skip__ = true
    end

    def should_skip?()
      @skip__
    end

    def reset_skip()
      @skip__ = false
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
