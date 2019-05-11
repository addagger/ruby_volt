module RubyVolt
  class DataType
    class Timestamp < Long
      
      class << self
        def pack(val)
          # All dates are represented on the wire as Long values. This signed number represents the number of microseconds before or after Jan. 1 1970 00:00:00 GMT, the Unix epoch. Note that the units are microseconds, not milliseconds.
          val = case val
          when ::Integer then val
          when ::Time then val.to_i*1000000 + val.usec # Microseconds
          end
          super(val)
        end
      
        def unpack(bytes)
          if unpacked = super(bytes)
            Time.at(unpacked/1000000.to_f) # Microseconds
          end
        end
      end
      
    end
  end
end