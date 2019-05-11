module RubyVolt
  class LoginMessage < Message
    
    def initialize(*args)
      super
      servicename, username, password = *args[1..-1]
      wrap do
        msg << DataType::Byte.pack(protocol) if protocol > 0 # Password hash version SHA-1 / SHA-256
        msg << DataType::String.pack(servicename) # Service name
        msg << DataType::String.pack(username) # Username
        msg << (protocol > 0 ? Digest::SHA2.digest(password) : Digest::SHA1.digest(password)) # Password
      end
    end
    
  end
end
  