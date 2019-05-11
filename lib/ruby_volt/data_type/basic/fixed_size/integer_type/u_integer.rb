module RubyVolt
  class DataType
    class UInteger < IntegerType # Unsigned
      DIRECTIVE = 'L>'
      LENGTH = 4
      NULL_INDICATOR = 0 # SQL NULL indicator for object type serializations
    end
  end
end