module RubyVolt
  class VoltTable
    attr_reader :index, :total_table_length, :total_metadata_length, :status_code, :columns, :rows

    def initialize(index, total_table_length, total_metadata_length, status_code, columns, rows = [])
      @index = index
      @total_table_length = total_table_length
      @total_metadata_length = total_metadata_length
      @status_code = status_code
      @columns = columns
      @row = ::Struct.new(*columns.map {|c| c[0].to_sym})
      @rows = []
      rows.each {|r| add_struct(r)}
    end
    
    def inspect
      "#<#{self.class.name} index=#{@index} total_table_length=#{@total_table_length} total_metadata_length=#{@total_metadata_length} rows=#{@rows.size}>"
    end
    
    def column_names
      columns.map(&:last)
    end

    def struct(*row)
      @row.new(*row)
    end

    def add_struct(row)
      @rows << struct(*row)
    end
          
    def method_missing(m, *args, &block)  
      rows.send(m, *args, &block)
    end
    
  end
end
