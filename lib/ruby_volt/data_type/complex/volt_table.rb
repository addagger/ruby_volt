module RubyVolt
  class DataType
    class VoltTable < Complex
      
      class << self
        def pack(columns, rows)
          # The "Table Metadata Length" stores the length in bytes of the contents of the table from byte 8 (the end of the metadata length field) all the way to the end of the "Column Names" sequence. NOTE: It does not include the row count value. See below for an example.
          status_code = ProcedureCallStatusCode.pack(0) # OK Status code
          columns_sequence = pack_columns(columns) # Columns data
          rows_sequence = pack_rows(columns, rows) # Rows data
          table_metadata_length = status_code.bytesize + columns_sequence.bytesize # Table Metadata Length
          total_table_length = table_metadata_length + rows_sequence.bytesize # Total Table Length
          [Integer.pack(total_table_length),
           Integer.pack(table_metadata_length),
           status_code,
           columns_sequence,
           rows_sequence].join
        end
      
        def unpack(bytes, &block)
          table_info = unpack_table_info(bytes)
          columns = unpack_columns(bytes)
          rows = unpack_rows(columns, bytes, &block)
          [*table_info, columns, rows]
        end
      
        def unpack_table_info(bytes)
          [Integer.unpack(bytes), # total_table_length
           Integer.unpack(bytes), # table_metadata_length
           ProcedureCallStatusCode.unpack(bytes)] # status_code
        end
      
        def pack_columns(columns = []) # [["column", DataType]] ex.: [["city", :String], ["population", :Long]]
          # The size of the "Column Types" and "Column Names" sequences is expected to equal the value stored in "Column Count".
          # Column names are limited to the ASCII character set. Strings in row values are still UTF-8 encoded.
          # Values with 4-byte (integer) length fields are signed and are limited to a max of 1 megabyte.
          col_types, col_names = [], []
          columns.each do |col|
            col_name, dataType = *col
            col_name = "modified_tuples" if col_name == ""
            dataType = classifyDataType(dataType) unless dataType < DataType
            col_types << WireTypeInfo.pack(dataType)
            col_names << Varbinary.pack(col_name) # ASCII-8bit
          end
          Short.pack(columns.size) + col_types.join + col_names.join
        end
    
        def unpack_columns(bytes)
          columns_count = Short.unpack(bytes)
          columns = columns_count.times.map do
            WireTypeInfo.unpack(bytes)
          end
          columns.map do |dataType|
            col_name = Varbinary.unpack(bytes) # ASCII-8bit
            col_name = "modified_tuples" if col_name == ""
            [col_name, dataType]
          end
        end
      
        def pack_rows(columns, rows = []) # [[val1, val2, ...]]
          # Each row is preceded by a 4 byte integer that holds the length of the row not including the length. For example, if a row is a single 4-byte integer column, the value of this length prefix will be 4. Row size is artificially restricted to 2 megabytes.
          # The body of the row is packed array of values. The value at index i is is of type specified by the column type field for index i.
          Integer.pack(rows.size) + # Row count
          rows.map do |row_values|
            rlength = 0
            row_values.map.with_index do |val, index|
              dataType = columns[index][1]
              packed = dataType.pack(val)
              rlength += packed.bytesize
              packed
            end.join.prepend(Integer.pack(rlength))
          end.join
        end
                        
        def unpack_rows(columns, bytes, &block) # Block for parsing on fly
          rows_count = Integer.unpack(bytes)
          rows = []
          rows_count.times do
            Integer.unpack(bytes) # Bytesize of row length
            row = columns.map do |c|
              dataType = c[1]
              dataType.unpack(bytes)
            end
            if block_given?
              yield(row)
            else
              rows << row
            end
          end
          rows
        end
      end
      
    end
  end
end