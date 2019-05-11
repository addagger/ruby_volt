module RubyVolt
  class DataType
    class Long < IntegerType
      DIRECTIVE = 'q>'
      LENGTH = 8
      NULL_INDICATOR = -9223372036854775808 # SQL NULL indicator for object type serializations
    end
  end
end