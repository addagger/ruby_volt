module RubyVolt
  class DataType
    class Null < Byte
      
      class << self
        def pack(*)
          super(Byte::NULL_INDICATOR)
        end
      end
      
    end
  end
end