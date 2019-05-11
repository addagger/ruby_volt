module RubyVolt
  class LoginResponse < Response

    # A response is generated to a login request and success is indicated with a result code of 0. Any other value indicates authentication failure and will be followed by the server closing the connection. A response code of 1 indicates that the there are too many connections. A response code of 2 indicates that authentication failed because the client took too long to transmit credentials. A response code of 3 indicates a corrupt or invalid login message. If the response code is 0 the response will also contain additional information following the result code. A 4 byte integer specifying the host id of the Volt node . An 8 byte long specifying a connection id that is unique among connections to that node. An 8 byte long timestamp (milliseconds since Unix epoch) and a 4 byte IPV4 address representing the time the cluster was started and the address of the leader node. These two values uniquely identify a Volt cluster instance. And finally a string containing a textual description of the build the node being connected to is running.
    
    def unpack!(&block)
      wrap do
        data[:auth_result] = DataType::Byte.unpack(bytes) # Authentication result code
  
        case data[:auth_result]
        when -1 then raise(AuthenticationRejected, "Authentication rejected! wrong username or password")
        when 1 then raise(TooManyConnections, "Too many connections")
        when 2 then raise(TooLongToTransmitCredentials, "Too long to transmit credentials")
        when 3 then raise(InvalidLoginMessage, "Corrupt or invalid login message")
        when 0 then
          data[:server_host_id] = DataType::Integer.unpack(bytes) # Server Host ID
          data[:connection_id] = DataType::Long.unpack(bytes) # Connection ID
          data[:cluster_start_ms] = DataType::Long.unpack(bytes) # Cluster start timestamp (milliseconds since Unix epoch)
          data[:leader_ipv4] = DataType::UInteger.unpack(bytes) # Leader IPV4 address
          data[:leader_ipv4] = IPAddr.new(data[:leader_ipv4], ::Socket::AF_INET) if data[:leader_ipv4]
          data[:build_str] = DataType::String.unpack(bytes) # Build string (variable)
        end
      end
    end
          
  end
end