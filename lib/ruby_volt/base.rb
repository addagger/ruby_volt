module RubyVolt
  class Base
    
    class AsyncCall
      attr_reader :opaque, :args, :response_msg
      
      def initialize(procedure, *parameters)
        @opaque = Helper.uniq_bytes(8) # Not even necessary
        @args = [procedure, @opaque, *parameters]
        @queue = SizedQueue.new(1)
      end
      
      def inspect
        "#<#{self.class} ready=#{!@queue.empty?}>"
      end
      
      def accept_response(response_msg)
        @queue.push(response_msg)
        @queue.close
      end
      
      def dispatch(&block)
        if @response_msg ||= @queue.pop
          InvocationResponse.new(@response_msg).unpack!(&block)
        end
      end 
    end
    
    attr_reader :login_protocol, :procedure_protocol, :servicename, :connect_timeout, :procedure_timeout, :connection_pool, :requests_queue
          
    def initialize(options = {})
      @login_protocol = options[:login_protocol]||LOGIN_PROTOCOL
      @procedure_protocol = options[:procedure_protocol]||PROCEDURE_PROTOCOL
      @servicename = options[:servicename]||SERVICE_NAME
      @connect_timeout = options[:connect_timeout]||CONNECT_TIMEOUT # timeout (secs) or Nil for authentication (default=8)
      @procedure_timeout = options[:procedure_timeout]||PROCEDURE_TIMEOUT # timeout (secs) or Nil for procedure call (default=8)
      @requests_queue = Queue.new
      @connection_pool = configure_pool(options)
      # You can create the connection to any of the nodes in the database cluster and your stored procedure will be routed appropriately. In fact, you can create connections to multiple nodes on the server and your subsequent requests will be distributed to the various connections.
      @connection_pool.each do |connection|
        Thread.new do
          begin
            while async_call = @requests_queue.pop
              response_msg = connection.call_procedure(*async_call.args)
              async_call.accept_response(response_msg)
            end
          rescue ThreadError
          end
        end
      end
    end
    
    def async_call_procedure(procedure, *parameters)
      AsyncCall.new(procedure, *parameters).tap do |async_call|
        @requests_queue.push(async_call)
      end
    end
    
    def call_procedure(*args, &block)
      async_call_procedure(*args).dispatch(&block)
    end
    
    def ping
      call_procedure("@Ping")
    end
    
    def benchmark(cycle = 1000)
      Helper.benchmark(cycle) {ping} # call @Ping - system stored procedure & dispatch
    end
    
    private
    
    def configure_pool(options)
      cluster = case options[:cluster]
      when nil then {DEFAULT_HOSTNAME => 0} # default hostname "localhost"
      when String then {options[:cluster] => 0}
      when Array then Hash[options[:cluster].map {|node| [node, 0]}]
      when Hash then options[:cluster].transform_values {|cnum| cnum.to_i.abs}
      else
        raise(TypeError, "Cluster definition has to be Hash, Array, String or Nil (default)")
      end

      zero_nodes = cluster.values.count {|cnum| cnum == 0} # non defined connection number
      if zero_nodes > 0
        connections = options[:connections]||1
        connections -= cluster.values.sum # user defined connections
        connections = zero_nodes if zero_nodes > connections
        for_each, extra = *connections.divmod(zero_nodes)
        cluster.transform_values!.with_index do |cnum, i|
          cnum > 0 ? cnum : (i < extra ? for_each + 1 : for_each)
        end
      end
      
      cluster.map do |node, per_node|
        uri = URI.parse("//#{node}")
        host = uri.host
        port = uri.port||DEFAULT_PORT # default TCP port 21212
        username = uri.user||options[:username]||"" # authentication user name for connection or Nil
        password = uri.password||options[:password]||"" # authentication password for connection or Nil
        per_node.times.map {Connection.new(self, host, port, username, password)}
      end.flatten
    end
    
  end
end