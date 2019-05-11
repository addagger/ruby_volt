module RubyVolt
  class DataType
    class Array < Compound
      # Arrays are represented as Byte value indicating the wire type of the elements and a 2 byte Short value indicating the number of elements in the array, followed by the specified number of elements. The length preceding value for the TINYINT (byte) type is length preceded by a 4 byte integer instead of a 2 byte short. This important exception allows large quantities of binary or string data to be passed as a byte array, and allows the serialization of and array of TINYINTs (bytes) to match the serialization of VARBINARY. Each array is serialized according to its type (Strings as Strings, VoltTables as VoltTables, Integers as Integers). Arrays are only present as parameters in parameter sets. Note that it is possible to pass an array of arrays of bytes if they are serialized as an array of VARBINARY types.
      
      class << self
        def pack(val = []) # First element is a DataType indicator (DataType itself, Integer, String/Symbol)
          array = val[1..-1]
          dataType = classifyDataType(val[0])
          unless dataType  # No indicator recognized
            array = val
            dataType = autodetect_dataType(array)
          end
          countDataType = (dataType <= Byte) ? Integer : Short # The length preceding value for the TINYINT (byte) type is length preceded by a 4 byte integer instead of a 2 byte short.
          WireTypeInfo.pack(dataType) + countDataType.pack(array.size) + array.map {|e| dataType.pack(e)}.join
        end
      
        def unpack(bytes)
          if dataType = WireTypeInfo.unpack(bytes)
            array = [dataType]
            countDataType = (dataType <= Byte) ? Integer : Short
            array_size = countDataType.unpack(bytes)
            array_size.times do
              array << dataType.unpack(bytes)
            end
            array
          end
        end
      
        def autodetect_dataType(array)
          if array[0].is_a?(::Integer)
            max_int = array.select {|e| e.is_a?(::Integer)}.max
            voltDataType(max_int)
          else
            voltDataType(array[0])
          end
        end
      end
      
    end
  end
end