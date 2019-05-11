module RubyVolt
  class DataType
    class Short < IntegerType
      DIRECTIVE = 's>'
      LENGTH = 2
      NULL_INDICATOR = -32768 # SQL NULL indicator for object type serializations
    end
  end
end