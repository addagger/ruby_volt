module RubyVolt
  class Response
    attr_reader :bytes, :data
    
    def initialize(*args)
      @bytes = case args[0]
      when ::IO, ReadPartial then args[0]
      else ReadPartial.new(args[0]) # Partial reader
      end
      @data = {}
    end
    
    def wrap(&block)
      # data[:length] = DataType::Integer.unpack(bytes) # Message length
      data[:protocol] = DataType::Byte.unpack(bytes) # Protocol version
      yield
      self
    end
    
  end
end

require 'ruby_volt/response/login_response'
require 'ruby_volt/response/invocation_response'