module RubyVolt
  class DataType
    class FixedSize < Basic
      
      class << self
        def pack(val)
          val ||= self::NULL_INDICATOR
          [val].pack(self::DIRECTIVE)
        end
  
        def unpack(bytes)
          unpacked = bytes.read(self::LENGTH).unpack1(self::DIRECTIVE)
          unpacked unless unpacked == self::NULL_INDICATOR
        end
      end
      
    end
  end
end

require 'ruby_volt/data_type/basic/fixed_size/integer_type'
require 'ruby_volt/data_type/basic/fixed_size/float'
require 'ruby_volt/data_type/basic/fixed_size/geography_point'
require 'ruby_volt/data_type/basic/fixed_size/timestamp' # Date
require 'ruby_volt/data_type/basic/fixed_size/decimal'
require 'ruby_volt/data_type/basic/fixed_size/null'
