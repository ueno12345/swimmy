#
# 住所，ランドマークの名前，駅の名前などから，経度緯度返すサービス
#
# ou = Swimmy::Service::Geocoding.new.find_location("岡山大学")
# puts "#{ou.name} = #{ou.lng},#{ou.lat}"
#   =>  岡山大学 = 133.922223,34.687387
# ou.class
#   => Swimmy::Resource::Place
#
# Swimmy::Service::Geocoding.new.find_location("山山大学")
#   => Swimmy::Service::Geocoding::NotFoundError
#
module Swimmy
  module Service
    class Geocoding
      require 'open-uri'
      require 'rexml/document'

      class NotFoundError < StandardError; end

      def find_location(place_name)
        encoded_address = URI.encode(place_name)

        uri = "http://www.geocoding.jp/api/?q=#{encoded_address}"
        doc = REXML::Document.new(open(uri).read)

        raise NotFoundError if doc.elements['result/error']

        lng = doc.elements['result/coordinate/lng'].text.to_f
        lat = doc.elements['result/coordinate/lat'].text.to_f
        return Resource::Place.new(place_name, lng, lat)
      end
    end # class Geolocation
  end # module Service
end # module Swimmy
