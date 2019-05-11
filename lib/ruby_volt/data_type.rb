module RubyVolt
  class DataType
    class << self
      def voltDataType(val) # Ruby data type => Wire::DataType conversion
        case val
        when ::Array then Array
        when NilClass then Null # Byte::NULL_INDICATOR
        when ::Integer then
          case val.bit_length
          when (0..7) then Byte
          when (8..15) then Short
          when (16..31) then Integer
          else
            Long if val.bit_length >= 32
          end
        when ::Float then Float
        when ::String then
          val.encoding.name == "UTF-8" ? String : Varbinary # See "sometext".encoding
        when ::Time then Timestamp
        when ::BigDecimal then Decimal
        when Meta::Geography::Point then GeographyPoint
        when Meta::Geography::Polygon then Geography
        end
      end
    
      def classifyDataType(val)
        case val
        when Class then val if val < DataType
        when ::String, ::Symbol then
          begin
            DataType.const_get(val)
          rescue
            nil
          end
        end
      end
    
      def testpacking(*vals)
        unpack(ReadPartial.new(pack(*vals)))
      end
    end
    
  end
end

require 'ruby_volt/data_type/extensions'
require 'ruby_volt/data_type/basic'
require 'ruby_volt/data_type/compound'
require 'ruby_volt/data_type/complex'
require 'ruby_volt/data_type/app_data_type'