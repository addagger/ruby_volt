module RubyVolt
  class DataType
    class ParameterSet < Complex
      
      class << self
        def pack(*vals)
          params_count = vals.size
          Short.pack(params_count) + vals.map {|val| Parameter.pack(val)}.join
        end
      
        def unpack(bytes)
          params_count = Short.unpack(bytes)
          params_count.times.map {Parameter.unpack(bytes)}
        end
      end
      
    end
  end
end