# Yutaro Takaie / nomlab
# This is a part of https://github.com/nomlab/swimmy

require "pp"

module Swimmy
  module Command
    class RainInformation < Base
      match(/(?:(?<place>\S+)の)?雨の状況/) do |client, data, match|
        place = (match[:place] || "岡山大学")
        client.say(channel: data.channel, text: "#{place}の天気取得中…")

        begin
          location = Service::Geocoding.new.find_location(place)
          weather = Service::Weather.new(ENV['YAHOO_API_KEY']).fetch_weather(location)
          message = weather.to_s
        rescue Service::Geocoding::NotFoundError
          message = "#{place}の位置情報が分かりませんでした．"
        rescue Service::Weather::NotFoundError
          message = "#{place}の天気が分かりませんでした(もしかして国外?)．"
        ensure
          message ||= "#{place}の天気の取得に失敗しました"
          client.say(channel: data.channel, text: message)
        end
      end

      help do
        title "rain_information"
        desc "雨の状況を教えてくれます．"
        long_desc "「XXの雨の状況」とつぶやいてみてください\n" +
                  "XXは，都市名です．例: 岡山の雨の状況\n" +
                  "都市名を省略して「雨の状況」だと岡山大学周辺の雨の状況を知らせます．\n"
      end
    end # class RainInformation
    end # module Command
end # module Swimmy
