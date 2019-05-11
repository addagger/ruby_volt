module RubyVolt
  class Message
    attr_reader :msg, :protocol
    
    def initialize(*args)
      @protocol = args[0]
      @msg = ::String.new
    end
    
    def inspect
      to_str.dump
    end
    
    def to_str
      msg
    end
          
    def wrap(&block)
      msg << DataType::Byte.pack(protocol) # VoltDB Wire Protocol Version
      yield(msg)
      msg.prepend(DataType::Integer.pack(msg.bytesize)) # Message length preceded
      self
    end
    
  end
end

require 'ruby_volt/message/login_message'
require 'ruby_volt/message/invocation_request'