module RubyVolt
  class InvocationRequest < Message
    
    def initialize(*args)
      super
      procedure, client_data = *args[1..2]
      raise(ClientDataInvalid, "Client data 8 bytes awaiting") if client_data.bytesize != 8
      parameters = args[3..-1]
      wrap do
        msg << DataType::String.pack(procedure) # Procedure name
        msg << [client_data].pack('a8') # Opaque client data (8 bytes)
        msg << DataType::ParameterSet.pack(*parameters) # Parameter set
      end
    end
    
  end
end
  