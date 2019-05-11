module RubyVolt
  module Meta
    module Geography
      class Point
        attr_reader :lng, :lat
      
        # The wire protocol representation is similar to the S2 representation which is used in the Execution Engine. This format is different from the Java longitude/latitude format, so some explanation is in order. In Java a point is represented by a longitude and latitude. In the wire protocol a point is represented by a three dimensional point on the unit sphere. These three dimensional points are called XYZPoints. Each dimension is a double precision IEEE floating point number. The Euclidean length of each XYZPoint must be 1.0.
      
        class << self
          def from_XYZPoint(x, y, z)
            degreesPerRadian = 180.0/Math::PI
            lngRadians = Math.atan2(y, x)
            latRadians = Math.atan2(z, Math.sqrt(x * x + y * y))
            lng = (lngRadians * degreesPerRadian).round(6)
            lat = (latRadians * degreesPerRadian).round(6)
            new(lng, lat)
          end
        end
        
        def initialize(lng, lat)
          raise(::ArgumentError, "Longitude must be in the range -180 ≤ longitude ≤ 180") unless lng >= -180 && lng <= 180
          raise(::ArgumentError, "Latitude must be in the range -90 ≤ latitude ≤ 90") unless lat >= -90 && lat <= 90
          @lng = lng
          @lat = lat
        end
    
        def to_XYZPoint
          radiansPerDegree = (Math::PI/180.0) # A conversion factor.
          latRadians = lat * radiansPerDegree # latitude is in degrees.
          lngRadians = lng * radiansPerDegree # longitude is in degrees.
          cosPhi = Math.cos(latRadians)
          x = Math.cos(lngRadians) * cosPhi
          y = Math.sin(lngRadians) * cosPhi
          z = Math.sin(latRadians)
          [x, y, z]
        end
      
        def inspect
          to_wkt
        end
      
        def to_s
          "#{lng} #{lat}"
        end
    
        def to_wkt
          "POINT(#{to_s})"
        end
      
        def ==(other)
          other.is_a?(Point) && (lng == other.lng) && (lat == other.lat)
        end
      
      end
  
      class Ring
        attr_reader :points
      
        def initialize(points = [])
          @points = []
          points.each {|point| add_point(point)}
        end
      
        def add_point(point)
          raise(::ArgumentError, "Point has to be represented by a pseudo container RubyVolt::Meta::Geography::Point") unless point.is_a?(Point)
          @points << point unless @points.include?(point)
        end
        
        def inspect
          to_wkt
        end
        
        def fork_reverse_points
          Ring.new(reverse_points)
        end
        
        def reverse_points!
          @points = reverse_points
          self
        end
        
        def reverse_points
          points[1..-1].reverse.prepend(points[0])
        end
        
        def close_points
          (points[-1] == points[0]) ? points : points + [points[0]]
        end
        
        def to_s
          "(#{close_points.join(", ")})"
        end
    
        def to_wkt
          "LINESTRING#{to_s}"
        end
      
        def ==(other)
          other.is_a?(Ring) && (points.size == other.points.size) && eval(points.map.with_index {|point, index| point == other.points[index]}.join("&&"))||true
        end
      
      end
  
      class Polygon
        attr_reader :rings
      
        # In the wire protocol the first ring is still the exterior boundary and subsequent rings are holes. However, in the wire protocol all rings, exterior and hole alike, must be counter clockwise, and the last point should not be equal to the first point.
      
        def initialize(rings = [])
          @rings = []
          rings.each {|ring| add_ring(ring)}
        end
      
        def add_ring(ring)
          raise(::ArgumentError, "LineString has to be represented by a pseudo container RubyVolt::Meta::Geography::Ring") unless ring.is_a?(Ring)
          @rings << ring
        end
      
        def holes
          has_holes? ? rings[1..-1] : []
        end
      
        def has_holes?
          rings.size > 1
        end
        
        def fork_transform_rings!
          Polygon.new(transform_rings)
        end
        
        def transform_rings!
          @rings = transform_rings
          self
        end
        
        def transform_rings
          # To transform a ring [from Java] representation to wire protocol representation one must:
          # • Remove the last vertex, which is the same as the first vertex,
          # • Transform the coordinates to XYZPoint values, and
          # • Reverse the order of the rings from the second to the end.
          rings.map.with_index do |ring, index|
            index > 0 ? ring.fork_reverse_points : ring
          end.compact
        end
          
        def inspect
          to_wkt
        end
      
        def to_s
          rings.join(", ")
        end
    
        def to_wkt
          "POLYGON(#{to_s})"
        end
      
        def ==(other)
          other.is_a?(Polygon) && (rings.size == other.rings.size) && eval(rings.map.with_index {|ring, index| ring == other.rings[index]}.join("&&"))||true
        end
      
      end
    end
  end
end