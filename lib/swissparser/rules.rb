module Swiss

  class Rules
    
    DEFAULT_SEPARATOR = "//"

    attr_reader :separator, :rules

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

    def define_parser( &body )
      Parser.new( self, body )
    end
    
    def refine( &proc )
      new_rules = Rules.new( @separator, copy( @rules ), copy( @helpers) )
      new_rules.instance_eval(&proc)
      new_rules
    end

    def get_helpers
      @helpers
    end

    private

    def with( key, &proc )
      @rules[key] = proc
    end

    def helpers( &proc )
      @helpers << proc
    end

    def with_text_after( key, &proc )
      @rules[:text][key] = proc
    end

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
