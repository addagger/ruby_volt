require 'minitest/autorun'
require 'ruby_volt'

class TestRubyVolt < Minitest::Test
  
  # Connection tests
  
  def test_connection
    base = RubyVolt::Base.new(:cluster => ["localhost"], :username => "addagger", :password => "interface")
    assert_equal 0, base.ping.result[0].rows[0].STATUS
  end
  
  # Packing: FIXED SIZE DATA STRUCTURES
  
  def test_packing_byte
    assert_equal (-1), RubyVolt::DataType::Byte.testpacking(-1)
    assert_nil RubyVolt::DataType::Byte.testpacking(nil)
  end
  
  def test_packing_short
    assert_equal (-1), RubyVolt::DataType::Short.testpacking(-1)
    assert_nil RubyVolt::DataType::Short.testpacking(nil)
  end
  
  def test_packing_integer
    assert_equal (-1), RubyVolt::DataType::Integer.testpacking(-1)
    assert_nil RubyVolt::DataType::Integer.testpacking(nil)
  end
  
  def test_packing_long
    assert_equal (-1), RubyVolt::DataType::Long.testpacking(-1)
    assert_nil RubyVolt::DataType::Long.testpacking(nil)
  end
  
  def test_packing_ubyte
    assert_equal 1, RubyVolt::DataType::UByte.testpacking(1)
    assert_nil RubyVolt::DataType::UByte.testpacking(nil)
  end
  
  def test_packing_ushort
    assert_equal 1, RubyVolt::DataType::UShort.testpacking(1)
    assert_nil RubyVolt::DataType::UShort.testpacking(nil)
  end
  
  def test_packing_uinteger
    assert_equal 1, RubyVolt::DataType::UInteger.testpacking(1)
    assert_nil RubyVolt::DataType::UInteger.testpacking(nil)
  end
  
  def test_packing_ulong
    assert_equal 1, RubyVolt::DataType::ULong.testpacking(1)
    assert_nil RubyVolt::DataType::ULong.testpacking(nil)
  end
  
  def test_packing_float
    assert_equal 3.14, RubyVolt::DataType::Float.testpacking(3.14)
    assert_nil RubyVolt::DataType::Float.testpacking(nil)
  end
  
  def test_packing_decimal
    assert_equal BigDecimal("-1234.56789"), RubyVolt::DataType::Decimal.testpacking("-1234.56789")
    assert_nil RubyVolt::DataType::Decimal.testpacking(nil)
  end
  
  def test_packing_null
    assert_nil RubyVolt::DataType::Null.testpacking(nil)
  end
  
  def test_packing_geography_point
    geopoint = RubyVolt::Meta::Geography::Point.new(0.100000, 0.900000)
    assert_equal geopoint, RubyVolt::DataType::GeographyPoint.testpacking(geopoint)
    assert_nil RubyVolt::DataType::GeographyPoint.testpacking(nil)
  end
  
  def test_packing_timestamp
    time = Time.now
    assert_equal time.to_i, RubyVolt::DataType::Timestamp.testpacking(time).to_i
    assert_nil RubyVolt::DataType::Timestamp.testpacking(nil)
  end
  
  # Packing: VARIABLE SIZE DATA STRUCTURES
  
  def test_packing_varbinary
    assert_equal "Test string".b, RubyVolt::DataType::Varbinary.testpacking("Test string")
    assert_equal "".b, RubyVolt::DataType::Varbinary.testpacking("")
    assert_nil RubyVolt::DataType::Varbinary.testpacking(nil)
  end
  
  def test_packing_string
    assert_equal "Test string", RubyVolt::DataType::String.testpacking("Test string")
    assert_equal "", RubyVolt::DataType::String.testpacking("")
    assert_nil RubyVolt::DataType::String.testpacking(nil)
  end
  
  def test_packing_polygon
    p1 = RubyVolt::Meta::Geography::Point.from_XYZPoint 1.000000, 0.000000, 0.000000
    p2 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999848, 0.017452, 0.000000
    p3 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999695, 0.017450, 0.017452
    p4 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999848, 0.000000, 0.017452
    p5 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999997, 0.001745, 0.001745
    p6 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999875, 0.001745, 0.015707
    p7 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999753, 0.015705, 0.015707
    p8 = RubyVolt::Meta::Geography::Point.from_XYZPoint 0.999875, 0.015707, 0.001745
    ring1 = RubyVolt::Meta::Geography::Ring.new
    ring1.add_point(p1)
    ring1.add_point(p2)
    ring1.add_point(p3)
    ring1.add_point(p4)
    ring1.add_point(p1)
    ring2 = RubyVolt::Meta::Geography::Ring.new
    ring2.add_point(p5)
    ring2.add_point(p6)
    ring2.add_point(p7)
    ring2.add_point(p8)
    ring2.add_point(p5)
    polygon = RubyVolt::Meta::Geography::Polygon.new
    polygon.add_ring(ring1)
    polygon.add_ring(ring2)
    assert_equal polygon, RubyVolt::DataType::Geography.testpacking(polygon)
    assert_nil RubyVolt::DataType::Geography.testpacking(nil)
  end
  
  # Packing: COMPOUND (ARRAY) DATA STRUCTURES
  
  def test_packing_array
    array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 32000]
    assert_equal array, RubyVolt::DataType::Array.testpacking(array)[1..-1]
  end
  
  # Packing: VOLTDB DATA STRUCTURES
  
  def test_packing_procedure_call_status_codes
    RubyVolt::DataType::ProcedureCallStatusCode.codes.values.each do |exception|
      assert_equal exception, RubyVolt::DataType::ProcedureCallStatusCode.testpacking(exception)
    end
  end
  
  def test_packing_wire_type_info
    RubyVolt::DataType::WireTypeInfo.codes.values.each do |dataType|
      assert_equal dataType, RubyVolt::DataType::WireTypeInfo.testpacking(dataType)
    end
  end
  
  def test_packing_serializable_exception
    RubyVolt::DataType::SerializableException.codes.each do |pair|
      assert_equal [pair[1], nil], RubyVolt::DataType::SerializableException.testpacking(pair[0])
    end
  end
  
  def test_packing_parameter
    assert_equal "text_parameter", RubyVolt::DataType::Parameter.testpacking("text_parameter")
    assert_equal 1, RubyVolt::DataType::Parameter.testpacking(1)
    assert_nil RubyVolt::DataType::Parameter.testpacking(nil)
  end
  
  def test_packing_parameter_set
    params = [1, "text_parameter", 123456789, 3.14]
    assert_equal params, RubyVolt::DataType::ParameterSet.testpacking(*params)
  end
  
  def test_packing_volt_table
    columns = [["int", RubyVolt::DataType::Integer], ["string", RubyVolt::DataType::String], ["float", RubyVolt::DataType::Float]]
    rows = [[1, "Text", 1.1], [2, "Text2", 2.2], [3, "Text3", 3.3]]
    bytes = RubyVolt::ReadPartial.new(RubyVolt::DataType::VoltTable.pack(columns, rows))
    unpacked = RubyVolt::DataType::VoltTable.unpack(bytes)
    assert_equal columns, unpacked[3]
    assert_equal rows, unpacked[4]
  end
  
end