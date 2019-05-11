module RubyVolt
  class DataType
    class Geography < Basic
      DIRECTIVE = 'a'
      NULL_INDICATOR = -1 # SQL NULL indicator for object type serializations
      
      class << self
        def pack(polygon)
          if polygon.nil?
             # Like strings, GeographyValue begins with a 4-byte integer storing the number of bytes of raw data, followed by the raw data itself. The NULL GeographyValue has a length of -1 followed by 0 (zero) bytes of data. Unlike strings, there are no zero byte GeographyValue data values.
            Integer.pack(self::NULL_INDICATOR)
          else
            raw_data =
            Byte.pack(0) + # The first byte, byte0, is an encoding version, which tells whether certain fields need to be initialized by the Execution Engine. This is initially zero (0) and should be maintained on read.
            Byte.pack(1) + # The next byte, byte 1, is internal. It should be initially 1, and should be maintained on read.
            Byte.pack(polygon.has_holes? ? 1 : 0) + # The next byte, byte 2, is 1 if the polygon has holes and 0 if it does not.
            Integer.pack(polygon.rings.size) + # The next four bytes, bytes 3, 4, 5 and 6, comprise a 32 bit integer which gives the number of rings. Call this value `NRINGS`
            polygon.transform_rings.map do |ring| # NRINGS ring representations
              Byte.pack(0) + # The first byte of a ring tells if the ring is initialized. It is initially zero (0) and should be maintained on read.
              Integer.pack(ring.points.size) + # The next 4 bytes are a 32-bit integer containing the number of vertices in the ring. Call this number `NVERTS`.
              ring.points.map do |point| #The next `NVERTS*3*8` bytes are `NVERTS` triples of double precision floating point numbers, in the order `X`, `Y` and `Z`.
                xyz = point.to_XYZPoint
                xyz.map {|double| Float.pack(double)}
              end.join +
              ([0]*38).pack('c38') # The next 38 bytes contain a bounding box and some internal fields. They should all be initially zero (0) and should be maintained on read.
            end.join +
            ([0]*33).pack('c33') # The next 33 bytes, after all the vertices, should be initially zero (0) and should be maintained on read.
            raw_data.prepend(Integer.pack(raw_data.size))
          end
        end
      
        def unpack(bytes)
          if (length = Integer.unpack(bytes)) && (length != self::NULL_INDICATOR)
            Byte.unpack(bytes) # The first byte, byte 0, is an encoding version, which tells whether certain fields need to be initialized by the Execution Engine. This is initially zero (0) and should be maintained on read.
            Byte.unpack(bytes) # The next byte, byte 1, is internal. It should be initially 1, and should be maintained on read
            has_holes = Byte.unpack(bytes) # The next byte, byte 2, is 1 if the polygon has holes and 0 if it does not.
            rings_size = Integer.unpack(bytes)
            polygon = Meta::Geography::Polygon.new
            rings_size.times do
              ring = Meta::Geography::Ring.new
              Byte.unpack(bytes) # Ring is initialized. It is initially zero (0) and should be maintained on read.
              verticles_size = Integer.unpack(bytes)
              verticles_size.times do
                x = Float.unpack(bytes)
                y = Float.unpack(bytes)
                z = Float.unpack(bytes)
                point = Meta::Geography::Point.from_XYZPoint(x, y, z)
                ring.add_point(point)
              end
              bytes.read(38).unpack1('c38') # Blob of zeros. 38 bytes contain a bounding box and some internal fields. They should all be initially zero (0) and should be maintained on read.
              polygon.add_ring(ring)
            end
            bytes.read(33).unpack1('c33') # Blob of zeros. The next 33 bytes, after all the vertices, should be initially zero (0) and should be maintained on read.
            polygon.transform_rings! if has_holes == 1
            polygon
          end
        end
      end
    end
  end
end