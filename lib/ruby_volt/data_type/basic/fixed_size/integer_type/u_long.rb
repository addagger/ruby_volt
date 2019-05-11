module RubyVolt
  class DataType
    class ULong < IntegerType # Unsigned
      DIRECTIVE = 'Q>'
      LENGTH = 8
      NULL_INDICATOR = 0 # SQL NULL indicator for object type serializations
    end
  end
end