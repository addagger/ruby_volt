module RubyVolt
  class DataType
    class WireTypeInfo < AppDataType
      hash_codes [-99, Array], # ARRAY
                 [1, Null], # NULL
                 [3, Byte], # TINYINT
                 [4, Short], # SMALLINT
                 [5, Integer], # INTEGER
                 [6, Long], # BIGINT
                 [8, Float], # FLOAT
                 [9, String], # STRING
                 [11, Timestamp], # TIMESTAMP
                 [22, Decimal], # DECIMAL
                 [25, Varbinary], # VARBINARY
                 [26, GeographyPoint], # GEOGRAPHY_POINT
                 [27, Geography] # GEOGRAPHY
      

      
    end
  end
end