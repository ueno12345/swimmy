#
# 場所を表す
#
module Swimmy
  module Resource
    class Place
      attr_reader :name, :longitude, :latitude

      alias_method :lng, :longitude
      alias_method :lat, :latitude

      def initialize(name, longitude, latitude)
        @name, @longitude, @latitude = name, longitude, latitude
      end

      def to_s
        "#{name || 'Unknown'} -- lng,lat = #{lng},#{lat}"
      end

    end # class Place
  end # module Resource
end # module Swimmy
