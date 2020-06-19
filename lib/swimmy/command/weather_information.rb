# coding: utf-8
require 'json'
require 'uri'
require 'yaml'
require 'net/https'
require 'open-uri'

module Swimmy
  module Command
    class WeatherInformation < Swimmy::Command::Base
      class PlaceCode
        PLACE_TO_CODE = {"北海"=>"016010", "青森"=>"020010", "岩手"=>"030010",
                         "宮城"=>"040010", "秋田"=>"050010", "山形"=>"060010",
                         "福島"=>"070010", "茨城"=>"080010", "栃木"=>"090010",
                         "群馬"=>"100010", "埼玉"=>"110010", "千葉"=>"120010",
                         "東京"=>"130010", "神奈川"=>"140010", "新潟"=>"150010",
                         "富山"=>"160010", "石川"=>"170010", "福井"=>"180010",
                         "山梨"=>"190010", "長野"=>"200010", "岐阜"=>"210010",
                         "静岡"=>"220010", "愛知"=>"230010", "三重"=>"240010",
                         "滋賀"=>"250010", "京都"=>"260010", "大阪"=>"270000",
                         "兵庫"=>"280010", "奈良"=>"290010", "和歌山"=>"300010",
                         "鳥取"=>"310010", "島根"=>"320010", "岡山"=>"330010",
                         "広島"=>"340010", "山口"=>"350020", "徳島"=>"360010",
                         "香川"=>"370000", "愛媛"=>"380010", "高知"=>"390010",
                         "福岡"=>"400010", "佐賀"=>"410010", "長崎"=>"420010",
                         "熊本"=>"430010", "大分"=>"440010", "宮崎"=>"450010",
                         "鹿児島"=>"460010", "沖縄"=>"471010"}

        def find_all(str)
          places = PLACE_TO_CODE.select { |key, value| str.include?(key)}
          codes = places.values
          return codes
        end
      end

      class MakeMessage
        def make_weather_info(res, match)     
          title   = res['title']
          text    = res['description']['text']
          link    = res['link']        
          if match[:expression].include?("明日")
            weather = res['forecasts'][1]
          elsif match[:expression].include?("明後日")
            weather = res['forecasts'][2]
          else
            weather = res['forecasts'].first
          end
          weather_info = "#{weather['date']}の#{title}は「#{weather['telop']}」です。"
          if weather['temperature']['max'] != nil && weather['temperature']['min'] != nil then
            weather_info  = weather_info +
                            "この日の最高気温は#{weather['temperature']['max']['celsius']}℃、最低気温は#{weather['temperature']['min']['celsius']}℃です。"
          end
          weather_info = weather_info + "\n#{text}"
          return weather_info
        end
      end
      
      command "weather_info" do |client,data,match|
        message = match[:expression]
        
        if message == nil then
          send_message = "「weather_info XX YY」とつぶやいてみてください\n" +
                         "XXは，都道府県名です．YYは，「今日」，「明日」，「明後日」のいずれかです．例: weather_info 岡山 明日\n" +
                         "YYを省略して「weather_info XX」だと，XXで指定した都道府県の今日の天気予報を知らせます．\n"
        else
          codes = PlaceCode.new.find_all(message)
          if codes.length  == 0
            send_message = "都道府県名を1つ入力してください。"
          elsif codes.length > 1
            send_message = "入力した都道府県が多すぎます。"
          else
            ## weather informationの取得先(http://weather.livedoor.com/weather_hacks/webservice) ##
            uri_weather = "http://weather.livedoor.com/forecast/webservice/json/v1?city=#{codes[0]}"
            res = JSON.load(open(uri_weather).read)            
            send_message = MakeMessage.new.make_weather_info(res, match)
          end
        end
        client.say(channel: data.channel, text: send_message)
      end
      
      help do
        title "weather_information"
        desc "天気予報を教えてくれます．"
        long_desc "「weather_info XX YY」とつぶやいてみてください\n" +
                  "XXは，都道府県名です．YYは，「今日」，「明日」，「明後日」のいずれかです．例: weather_info 岡山 明日\n" +
                  "YYを省略して「weather_info XX」だと，XXで指定した都道府県の今日の天気予報を知らせます．\n"
      end
    end
  end
end
