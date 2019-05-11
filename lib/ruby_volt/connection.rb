require 'ruby_volt/message'
require 'ruby_volt/response'

module RubyVolt
  class Connection
    attr_reader :host, :port, :socket, :login_data
    
    def initialize(base, host, port, username, password)
      @host, @port = host, port
      @mutex = Mutex.new # Semaphore
      @opaque = Helper.uniq_bytes(8)
      define_singleton_method :base do
        base
      end
      define_singleton_method :login! do
        request = LoginMessage.new(login_protocol, servicename, username, password)
        response_msg = dialog!(request, connect_timeout)
        response = LoginResponse.new(response_msg).unpack!
        @login_data = response.data
        if logged_in?
          puts "=== VoltDB wired [#{host}:#{port}]: connection_id=#{login_data[:connection_id]}" if logged_in?
        end
      end
      establish!
    end
    
    def login_protocol
      base.login_protocol
    end
    
    def procedure_protocol
      base.procedure_protocol
    end
    
    def servicename
      base.servicename
    end
    
    def connect_timeout
      base.connect_timeout
    end
    
    def procedure_timeout
      base.procedure_timeout
    end
    
    def inspect
      "#<#{self.class.name} [#{host}:#{port}]: server_host_id=#{login_data[:server_host_id]} connection_id=#{login_data[:connection_id]} login_protocol=#{login_protocol} procedure_protocol=#{procedure_protocol}>"
    end
    
    def establish!
      close!
      attempts = 0
      begin
        @socket = ::Socket.tcp(host, port, nil, nil, {:connect_timeout => connect_timeout})
      rescue ::SystemCallError => e
        warn "#{e.class}: #{e}. Reinitializing connection..." unless attempts > 0
        attempts += 1
        retry
      else
        login!
      end
    end
    
    def socket_open?
      socket && !socket.closed?
    end
    
    def close!
      @login_data = nil
      if socket
        begin
          socket.close
        rescue
        ensure
          @socket = nil
        end
      end
    end
    
    def require_login!
      establish! unless logged_in?
    end
    
    def logged_in?
      login_data && login_data[:auth_result] == 0
    end
    
    def unavailable?
      !logged_in?||!socket_open?
    end
    
    def available?
      !unavailable?
    end
    
    def call_procedure(procedure, client_data = @opaque, *parameters)
      # The procedure invocation request contains the procedure to be called by name, and the serialized parameters to the procedure. The message also includes an opaque 8 byte client data value which will be returned with the response, and can be used by the client to correlate requests with responses.
      @mutex.synchronize do
        require_login!
        request = InvocationRequest.new(procedure_protocol, procedure, client_data, *parameters)
        dialog!(request, procedure_timeout) # Byte string
      end
    end
    
    def ping
      call_procedure("@Ping")
    end
    
    def benchmark(cycle = 1000)
      Helper.benchmark(cycle) {ping} # call @Ping - system stored procedure
    end
    
    private
    
    def dialog!(request, timeout = nil)
      begin
        socket.read(socket.nread) if socket_open? && socket.nread > 0 # Flush data waiting to be read
        socket.send(request.msg, 0) # Starting dialog
        io_select(:read, ReadTimeout, timeout) do # Waiting socket to be readable
          length = DataType::Integer.unpack(socket) # Unpacking 32-bit integer of message length
          readmsg(length) # Receiving message body
        end
      rescue ::SystemCallError, SocketDialogTimeout, ConnectionLostStatusCode => e
        warn "#{e.class}: #{e}."
        establish! unless request.is_a?(LoginMessage)
        retry
      end
    end
    
    def readmsg(length)
      msg = ::String.new(:capacity => length)
      socket.read(length, msg) # Reading message body
      ReadPartial.new(msg)
    end
    
    def io_select(action, exception_class, timeout = DEFAULT_TIMEOUT, &block)
      ready = case action
      when :read then IO.select([socket], nil, nil, timeout) # ready for read
      when :send then IO.select(nil, [socket], nil, timeout) # ready for write
      when :exception then IO.select(nil, nil, [socket], timeout) # ready for exceptions
      end
      # 1) IO.select takes a set of sockets and waits until it's possible to read or write with them (or if error happens). It returns sockets event happened with.
      # 2) array contains sockets that are checked for events. In your case you specify only sockets for reading.
      # 3) IO.select returns an array of arrays of sockets. Element 0 contains sockets you can read from, element 1 - sockets you can write to and element 2 - sockets with errors.
      ready ? yield : raise(exception_class, "#{timeout} sec data #{action} timed out")
    end
    
  end
end