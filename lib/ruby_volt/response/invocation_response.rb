module RubyVolt
  class InvocationResponse < Response
    attr_reader :result

    # An invocation response contains the results of the server's attempt to execute the stored procedure. The response includes optional fields and the first byte after the header is used to indicate which optional fields are present. The status string, application status string, and serializable exception are all optional fields. Bit 7 indicates the presence of a serializable exception, bit 6 indicates the presence of a status string, and bit 8 indicates the presence of an app status string. The serializable exception that can be included in some responses is currently not a part of the wire protocol. The exception length value should be used to skip exceptions if they are present. The status string is used to return any human readable information the server or stored procedure wants to return with the response. The app status code and app status string can be set by application code from within stored procedures and is returned with the response.
    
    def unpack!(&block)
      wrap do
        data[:client_data] = bytes.read(8).unpack1('a8')
    
        presentFields = DataType::Byte.unpack(bytes)
        data[:present_fields] = presentFields
    
        data[:status] = DataType::ProcedureCallStatusCode.unpack(bytes) # Status

        if presentFields & (1 << 5) != 0 # Bit 6 indicates the presence of a status string
          data[:status_string] = DataType::String.unpack(bytes) # Status string
        end
      
        data[:app_status] = DataType::Byte.unpack(bytes) # App status
      
        if presentFields & (1 << 7) != 0 # Bit 8 indicates the presence of an app status string
          data[:app_status_string] = DataType::String.unpack(bytes) # App status string
        end
      
        data[:cluster_round_trip_time] = DataType::Integer.unpack(bytes) # Cluster round trip time
      
        if presentFields & (1 << 6) != 0 # Bit 7 indicates the presence of a serializable exception
          data[:serialized_exception] = DataType::SerializableException.unpack(bytes) # Serialized exception
        end

        if data[:status] != SuccessStatusCode
          raise(data[:status], data[:status_string])
        end
      
        if data[:serialized_exception]
          raise(*data[:serialized_exception])
        end

        result_count = DataType::Short.unpack(bytes) # Result count
                  
        # VoltTables data
        @result = result_count.times.map do |index|
          table_info = DataType::VoltTable.unpack_table_info(bytes) # Total Table Length, Table Metadata Length, Status Code
          columns = DataType::VoltTable.unpack_columns(bytes) # Columns data
          volt_table = VoltTable.new(index, *table_info, columns)

          # Rows data
          DataType::VoltTable.unpack_rows(columns, bytes) do |row|
            if block_given?
              yield(data, volt_table, row)
            else
              volt_table.add_struct(row)
            end
          end
          
          volt_table
        end
      end
      
    end
          
  end
end