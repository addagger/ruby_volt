module RubyVolt
  class DataType
    class UShort < IntegerType # Unsigned
      DIRECTIVE = 'S>'
      LENGTH = 2
      NULL_INDICATOR = 0 # SQL NULL indicator for object type serializations
    end
  end
end