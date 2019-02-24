#
# お天気情報サービス
#
# Yahoo! Japan の API キーが必要
#   参考: 取得: https://e.developer.yahoo.co.jp/register
#         管理: https://e.developer.yahoo.co.jp/dashboard/
#
# APIが使えているかのチェック:
# curl "https://map.yahooapis.jp/weather/V1/place?output=json&coordinates=133.922223,34.687387&appid=YOUR_API_KEY"
#
# 利用例
#   # 岡山大学を表す Place オブジェクトを取得
#   ou = Swimmおy::Service::Geocoding.new.find_location("岡山大学")
#   # 天気予報サービスを生成 (Yahoo Japan! API_KEY を引数)
#   ws = Swimmy::Service::Weather.new("dj0za........YTk-")
#   # 天気予報を問合せ (Swimmy::Resource::Weather が返ってくる)
#   weather = ws.fetch_weather(ou)
#   # 結果を文字列で表示
#   puts weather
#
module Swimmy
  module Service
    class Weather
      require 'json'
      require 'net/http'

      class NotFoundError < StandardError; end

      def initialize(yahoo_api_key)
        @api_key = yahoo_api_key
      end

      # place に対する Swimmy::Resource::Weather オブジェクトを返す
      # place は，#lng, #lat メソッドを持つオブジェクト (Swimmy::Resource::Place)
      #
      def fetch_weather(place)
        base_uri = "https://map.yahooapis.jp/weather/V1/place"
        params = "output=json&coordinates=#{place.lng},#{place.lat}&appid=#{@api_key}"
        result = JSON.parse(Net::HTTP.get(URI.parse(base_uri + "?" + params)))

        rain_fall = result['Feature'][0]['Property']['WeatherList']['Weather']
        raise NotFoundError unless rain_fall[0]['Rainfall']

        rainfalls = []
        rain_fall.each_with_index do |time, i|
          rainfalls << time['Rainfall']
        end

        Swimmy::Resource::Weather.new(place, rainfalls)
      end
    end # class Weather
  end # class Service
end # class Swimmy
