module RubyVolt
  class DataType
    class UByte < IntegerType # Unsigned
      DIRECTIVE = 'C'
      LENGTH = 1
      NULL_INDICATOR = 0 # SQL NULL indicator for object type serializations
    end
  end
end