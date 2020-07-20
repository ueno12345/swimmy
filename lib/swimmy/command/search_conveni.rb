# coding: utf-8

# Miyake Takayoshi / nomlab
#This is a part of http://github.com/nomlab/swimmy

#Tis program uses "Google Place API"
#To konw more information, access below cite
#https://developers.google.com/places/web-service/search?hl=ja

require 'json'
require 'uri'
require 'net/https'
require 'slack-ruby-bot'

module Swimmy
  module Command
    class SearchConveni < Swimmy::Command::Base
      match(/(.+のコンビニ(\([1-9][0-9]*\))?)|(SearchConveni .+( [1-9][0-9]*)?)/) do |client,data,match|

        if data.text.match(/のコンビニ(\([1-9][0-9]*\))?/) != nil then
          address = $`
          if data.text.match(/\d+/) != nil then
            times = data.text.match(/\d+/)[0].to_i
          else
            times = 1
          end
        else
          address = data.text.split( )[1]
          if data.text.split( )[2] != nil then
            times = data.text.split( )[2].to_i
          else
            times = 1
          end
        end
          
        api = Api.new
        if api.set_param() == -1
          client.say(channel: data.channel, text:"'GOOGLE_PLACES_API_KEY'が設定されていません．")
        else
          client.say(channel: data.channel, text:"検索中...")
          response = api.fetch(address)
          message = api.formatter(response, times)
          client.say(channel: data.channel, text: message)
        end
      end

      help do
        title "SearchConveni"
        desc "指定した場所のコンビニを検索します．"
        long_desc "検索する地名を<address>，表示する件数を<number>として以下のように入力してください．\n" +
                  "SearchConveni <address> <number>\n" +
                  "または以下の書式でも検索できます．\n" +
                  "<address>のコンビニ(<number>)\n" +
                  "<number>は省略可能です．省略した場合，1件表示されます．"
      end
      
      class Api
        def set_param()
          @API_KEY = ENV['GOOGLE_PLACES_API_KEY']
          @PLACE_API_SEARCH_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
          @PLACE_API_DETAIL_URL = "https://www.google.com/maps/search/?api=1&query=Google&query_place_id="
          if @API_KEY == nil then
            return -1
          else
            return 0
          end
        end
        
        def fetch(address) 
          request_hash = {query: "#{address}",laungage: "ja",type: "convenience_store", key: "#{@API_KEY}"}
          request = URI.encode_www_form(request_hash)
          uri = URI.parse(@PLACE_API_SEARCH_URL + request)
          response =  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            http.get(uri.request_uri)
          end
          return JSON.parse(response.body)
        end
        
        def formatter(response, times)
          if response["status"] == "OK" then
            message = ""
            for i in 0..times-1
              if response.dig("results", i) == nil
                break
              else
                place_name = response.dig("results", i, "name")
                place_id = response.dig("results", i, "place_id")
                message = message + "#{place_name}\n #{@PLACE_API_DETAIL_URL}#{place_id}\n"
              end
            end
          elsif response["status"] == "ZERO_RESULTS" then
            message = "指定された場所にコンビニはありません．"
          elsif response["status"] == "REQUEST_DENIED" then
            message = "設定されている'GOOGLE_PLACES_API_KEY'が無効です．"
          else
            message = "検索に失敗しました．"
          end
          return message
        end
      end
    end
  end
end
  
