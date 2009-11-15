module Swiss

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

end
