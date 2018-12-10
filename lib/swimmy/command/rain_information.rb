# coding: utf-8
#
# Yutaro Takaie / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'rexml/document'
require 'open-uri'
require 'nkf'
require 'pp'
require 'net/http'
require 'singleton'
require 'kconv'
require 'slack-ruby-bot'

module Swimmy
  module Command
    class Rain_information < SlackRubyBot::Commands::Base
      match(/雨の状況/) do |client, data, match|
        json = {:user_name => data.user, :text => data.text}.to_json
        params = JSON.parse(json, symbolize_names: true)
        res = rain_info(params)
        text = JSON.parse(res)
        client.say(channel: data.channel, text: text["text"])
      end

      @yahoo_api = ENV['YAHOO_API_KEY']

      def self.get_locate(params)
        place_info = params[:text].sub(/の雨の状況.*/,'').sub(/.* /,'').sub(/\n/,'')

        p place_info
        encoded_address = URI.encode(place_info)
        url = "http://www.geocoding.jp/api/?q=" + encoded_address
        p url
        result = open(url).read.toutf8

        doc = REXML::Document.new(result)
        return "error" if doc.elements['result/error'] != nil

        lat = doc.elements['result/coordinate/lat'].text
        lng = doc.elements['result/coordinate/lng'].text
        return  lng + ',' + lat
      end


      def self.rain_info(params,options = {})
        text = ""
        base_uri = "https://map.yahooapis.jp/weather/V1/place?"
        output = "output=json"

        if (params[:text] !~ /の雨の状況/)
          place = "133.922223,34.687387"
        elsif (place = self.get_locate(params)) == "error"
          text = "not found\n"
          return {text: "#{text}"}.merge(options).to_json
        end

        p place
        client_id = "appid="
        rain_uri = base_uri + output + "&" + "coordinates=" + place + "&" + client_id + @yahoo_api

        p rain_uri

        uri = URI.parse(rain_uri)
        json = Net::HTTP.get(uri)
        result = JSON.parse(json)

        if  result['Feature'][0]['Property']['WeatherList']['Weather'][0]['Rainfall'] == nil
          text="Japan Only"
          return {text: "#{text}"}.merge(options).to_json
        end

        info = []
        (0..6).each do |num|
          info << result['Feature'][0]['Property']['WeatherList']['Weather'][num]['Rainfall']
        end

        (0..6).each do |num|
          text = text + "#{num*10}分後は #{rain_power(info[num])}(降水強度: #{info[num]}mm/h)\n"
        end

        return {text: "#{text}"}.merge(options).to_json
      end


      def self.rain_power(info)
        if info == 0 
          return "降っていない"
        elsif info < 10 
          return "雨"
        elsif info < 20 
          return "やや強い雨"
        elsif info < 30 
          return "強い雨"
        elsif info < 50 
          return "激しい雨"
        elsif info < 80 
          return "非常に激しい雨"
        elsif info >= 80
          return "猛烈な雨"
        else
          return "error"
        end
      end
    end
  end
end
