module RubyVolt
  class DataType
    class AppDataType < Byte
      extend Extensions::CodeValuesHash
      
      class << self
        def pack(val)
          val = val.is_a?(::Integer) ? val : code_values[val]
          super(val)
        end
      
        def unpack(bytes)
          if unpacked = super(bytes)
            codes[unpacked]
          end
        end
      end
      
    end
  end
end

require 'ruby_volt/data_type/app_data_type/procedure_call_status_code'
require 'ruby_volt/data_type/app_data_type/wire_type_info'