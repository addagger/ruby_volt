module RubyVolt
  class DataType
    class GeographyPoint < FixedSize
      DIRECTIVE = "G2"
      LENGTH = 16
      
      class << self
        def pack(point)
          # A GeographyPointValue's wire protocol representation is simply two double precision numbers in sequence. The first is the longitude, and must be in the range -180 ≤ longitude ≤ 180. The second is the latitude, and must be in the range -90 ≤ latitude ≤ 90. The null GeographyPoint value has longitude and latitude both equal to 360.0.
          if point.nil?
            lng, lat = 360.0, 360.0
          else
            lng, lat = point.lng, point.lat
          end
          [lng, lat].pack(self::DIRECTIVE)
        end
      
        def unpack(bytes)
          lng, lat = *bytes.read(self::LENGTH).unpack(self::DIRECTIVE)
          if (lng != 360.0) && (lat != 360.0)
            Meta::Geography::Point.new(lng, lat)
          end
        end
      end
      
    end
  end
end