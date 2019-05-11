require 'bigdecimal'
require 'bigdecimal/util'

module RubyVolt
  class DataType
    class Decimal < FixedSize
      DIRECTIVE = 'C16'
      NULL_INDICATOR = -170141183460469231731687303715884105728 # SQL NULL indicator for object type serializations
      LENGTH = 16
      PRECISION = 38
      SCALE = 12
      
      class << self
        def pack(val)
          ((val == self::NULL_INDICATOR) || val.nil?) ? intToBytes(self::LENGTH, self::NULL_INDICATOR) : serialize(val)
        end
  
        def unpack(bytes)
          if (unscaled = bytesToInt(self::LENGTH, bytes.read(self::LENGTH))) && (unscaled != self::NULL_INDICATOR)
            unscaled = unscaled.to_s
            scaled = unscaled.insert(unscaled.size - self::SCALE, ".")
            BigDecimal(scaled)
          end
        end
      
        def serialize(val)
          num = case val
          when BigDecimal then val
          else val.to_d
          end
          sign, digits, base, exponent = *num.split
          scale = digits.size - exponent
          precision = digits.size
          raise(::ArgumentError, "Scale of this decimal is #{scale} and the max is #{self::SCALE}") if scale > self::SCALE
          rest = precision - scale
          raise(::ArgumentError, "Precision to the left of the decimal point is #{rest} and the max is #{self::PRECISION-self::SCALE}") if rest > 26
          scale_factor = self::SCALE - scale
          unscaled_int = sign * digits.to_i * base ** scale_factor # Unscaled integer
          intToBytes(self::LENGTH, unscaled_int)
        end
      end
      
    end
  end
end