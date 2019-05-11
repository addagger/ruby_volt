module RubyVolt
  class DataType
    class Byte < IntegerType
      DIRECTIVE = 'c'
      LENGTH = 1
      NULL_INDICATOR = -128 # SQL NULL indicator for object type serializations
    end
  end
end