module RubyVolt
  class DataType
    class SerializableException < Basic
      extend Extensions::CodeValuesHash
      hash_codes [1, EEException],
                 [2, SQLException],
                 [3, ConstraintFailureException]
                 
      DIRECTIVE = 'a'
      NULL_INDICATOR = 0 # The ordinal will not be present if the exception's length is 0.

      class << self
        def pack(val, body = nil)
          if val.nil?
            Integer.pack(self::NULL_INDICATOR)
          else
            ordinal = val.is_a?(::Integer) ? val : code_values[val]
            if body
              Integer.pack(1 + body.bytesize) + Byte.pack(ordinal) + body # Exception ordinal (1 byte) + opaque length
            else
              Integer.pack(1) + Byte.pack(ordinal) # Exception ordinal (1 byte)
            end
          end
        end

        def unpack(bytes)
          if (length = Integer.unpack(bytes)) && length > 0
            ordinal = Byte.unpack(bytes)
            body_size = length - 1
            if body_size == 0 # Ordinal only, no body
              [codes[ordinal], nil]
            else
              [codes[ordinal], bytes.read(body_size).unpack1("#{self::DIRECTIVE}#{body_size}")]
            end
          else
            [nil, nil]
          end
        end
      end
      
    end
  end
end