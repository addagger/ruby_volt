module RubyVolt
  module Helper
    
    def self.benchmark(cycle = 1000, &block)
      start = Time.now
      cycle.times { yield }
      spend = Time.now - start
      puts "Execution time: #{spend} sec. #{(cycle/spend).round(2)} TPS."
    end
  
    def self.uniq_bytes(length = 8)
      bytes = ::String.new(:capacity => length)
      bytes <<
      if length > 0
        nsec = Time.now.nsec
        int = DataType::Integer.pack(nsec)
        if length/2 < 4
          int.b[-length/2..-1]
        else
          int
        end
      else
        ::String.new
      end
      bytes << SecureRandom.random_bytes(length - bytes.bytesize)
    end
    
  end
end