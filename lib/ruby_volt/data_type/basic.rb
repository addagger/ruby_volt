module RubyVolt
  class DataType
    class Basic < self
      
      class << self
        def intToBytes(length, value)
          bitlength = length*8
          div = nil
          x = [[32, 'N'], [16, 'n'], [8, 'C']].find {|a| (div = bitlength.divmod(a[0])) && div[0] != 0 && div[1] == 0}
          b = (2**x[0])-1
          ([value & b] + (2..div[0]).map {|i| (value >> x[0]*(i-1)) & b}).reverse.pack(x[1]*div[0])
        end
      
        def bytesToInt(length, bytes) # bytes = array of 8-bit unsigned
          bytes = bytes.unpack("C#{length}")
          most_significant_bit = 1 << 7
          negative = (bytes[0] & most_significant_bit) != 0
          unscaled_value = -(bytes[0] & most_significant_bit) << length*8-8
          # Clear the highest bit
          # Unleash the powers of the butterfly
          bytes[0] &= ~most_significant_bit
          # Get the 2's complement
          (0..length-1).each {|i| unscaled_value += bytes[i] << ((length-1 - i) * 8)}
          unscaled_value * -1 if negative
          unscaled_value
        end
      end
      
    end
  end
end

require 'ruby_volt/data_type/basic/fixed_size'
require 'ruby_volt/data_type/basic/varbinary'
require 'ruby_volt/data_type/basic/string'
require 'ruby_volt/data_type/basic/geography'
