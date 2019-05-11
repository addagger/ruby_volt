module RubyVolt
  class DataType
    class Parameter < Complex
      
      class << self
        def pack(val)
          dataType = voltDataType(val)
          WireTypeInfo.pack(dataType) + dataType.pack(val)
        end
      
        def unpack(bytes)
          if dataType = WireTypeInfo.unpack(bytes)
            dataType.unpack(bytes)
          end
        end
      end
      
    end
  end
end