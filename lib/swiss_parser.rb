module Swiss

  class Parser

    DEFAULT_SEPARATOR = "//"
    
    attr_accessor :separator

    def self.define( &proc )
      p = Parser.new
      proc.call( p )
      p
    end

    def initialize
      @actions = {}
      @actions[:text] = {}
      @separator = DEFAULT_SEPARATOR
      @before = Proc.new do
        []
      end
      @begin = Proc.new do 
        {}
      end
      @end = Proc.new do |entry,context|
        context << entry
      end
      @after = Proc.new do |context|
        context
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

    def with( key, &proc )
      @actions[key] = proc
    end

    def with_text_after( key, &proc )
      @actions[:text][key] = proc
    end

    def parse_file( filename )
      context = @before.call
      File.open( filename, 'r' ) do |file|
        entry = @begin.call
        file.each_line do |line|
          state = parse_line( line, entry )
          if state == :end
            @end.call( entry, context )
            entry = @begin.call
          end
        end
      end
      @after.call( context )
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
