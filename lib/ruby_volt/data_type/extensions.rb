module RubyVolt
  class DataType
    module Extensions
    
      module CodeValuesHash
        attr_reader :codes, :code_values

        def inherited(child)
          child.instance_variable_set(:@codes, Hash[@codes.map {|a| [a[0], a[1].dup]}]) if instance_variable_defined?("@codes")
        end

        def hash_codes(*arrays)
          @codes ||= Hash[arrays]
          @code_values ||= Hash[arrays.map(&:reverse)]
        end
      end
      
    end
  end
end