module RubyVolt
  class DataType
    class Varbinary < Basic
      DIRECTIVE = 'a'
      NULL_INDICATOR = -1 # SQL NULL indicator for object type serializations

      class << self
        def pack(val)
          if val.nil?
            Integer.pack(self::NULL_INDICATOR)
          else
            val = convert_input(val)
            Integer.pack(val.bytesize) + val
          end
        end
      
        def unpack(bytes)
          length = Integer.unpack(bytes)
          case length
          when self::NULL_INDICATOR then nil
          when 0 then ::String.new
          else
            bytes.read(length).unpack1("#{self::DIRECTIVE}#{length}")
          end
        end
      
        def convert_input(val)
          val.to_s.encode("ascii-8bit")
        end
      end
      
    end
  end
end