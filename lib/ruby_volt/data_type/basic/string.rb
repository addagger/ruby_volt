module RubyVolt
  class DataType
    class String < Varbinary
      
      class << self
        def unpack(bytes)
          if unpacked = super(bytes)
            unpacked.force_encoding("utf-8")
          end
        end
    
        def convert_input(val)
          val.to_s.encode("utf-8")
        end
      end
    
    end
  end
end