module Swiss

  class Parser

    DEFAULT_SEPARATOR = "//"
    
    attr_accessor :separator

    def initialize
      @actions = {}
      @actions[:text] = {}
      @separator = DEFAULT_SEPARATOR
    end

    def new_entry(&proc)
       @begin = proc
    end

    def with( key, &proc )
      @actions[key] = proc
    end

    def with_text_after( key, &proc )
      @actions[:text][key] = proc
    end

    def parse_file( filename )
      entries = []
      File.open( filename, 'r' ) do |file|
        entry = @begin.call
        file.each_line do |line|
          state = parse_line( line, entry )
          if state == :end
            entries << entry
            entry = @begin.call
          end
        end
      end
      entries
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
