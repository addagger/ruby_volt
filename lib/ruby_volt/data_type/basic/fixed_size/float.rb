module RubyVolt
  class DataType
    class Float < FixedSize
      DIRECTIVE = 'G'
      LENGTH = 8
      NULL_INDICATOR = -1.7E308 # SQL NULL indicator for object type serializations
    end
  end
end