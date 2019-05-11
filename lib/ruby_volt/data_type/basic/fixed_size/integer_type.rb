module RubyVolt
  class DataType
    class IntegerType < FixedSize
      # Reserved class
      
      class << self
      end
      
    end
  end
end

require 'ruby_volt/data_type/basic/fixed_size/integer_type/byte'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/u_byte'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/short'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/u_short'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/integer'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/u_integer'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/long'
require 'ruby_volt/data_type/basic/fixed_size/integer_type/u_long'