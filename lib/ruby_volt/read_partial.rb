module RubyVolt
  class ReadPartial
    def initialize(bytes)
      @bytes = bytes
    end
    
    def inspect
      "<#{self.class.name}: bytes=#{@bytes.bytesize}>"
    end
    
    def nread
      @bytes.bytesize
    end
    
    def read(num)
      exp = @bytes.byteslice(0, num)
      @bytes.delete_prefix!(exp)
      exp
    end
    
    alias_method :recv, :read
  end
end