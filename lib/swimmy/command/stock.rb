# coding: utf-8
module Swimmy
  module Command
    class Stock < Swimmy::Command::Base

      command "stock" do |client, data, match|

        case match[:expression]
        when /(\d+)/
          code = "#{$1.to_i}.T"
          stock = WorkHorse.new(code)

          stock.fetch
          client.say(channel: data.channel, text: stock.message("銘柄コード#{$1.to_i}の株価"))
        when nil
          code = "%5EN225"
          stock = WorkHorse.new(code)

          stock.fetch
          client.say(channel: data.channel, text: stock.message("日経平均株価"))
        else
          client.say(channel: data.channel, text: help_message("stock"))
        end
      end

      help do
        title "stock"
        desc "今日の国内の株価を教えてくれます．"
        long_desc "stock - 今日の日経平均株価の始値，高値，安値，終値を表示します．\n" +
                  "stock XXXX - 銘柄コードXXXXの今日の始値，高値，安値，終値を表示します．\n"
      end

      
      class WorkHorse
        require 'json'
        require 'uri'
        require 'net/http'

        def initialize(code)
          @uri ="https://query1.finance.yahoo.com/v8/finance/chart/#{code}?range=2d&interval=1d"
        end

        def fetch
          begin
            parsed_uri =URI.parse(@uri)
            request = Net::HTTP::Get.new(parsed_uri.request_uri)
            http = Net::HTTP.new(parsed_uri.host,parsed_uri.port)
            request['User-Agent'] = 'curl/7.64.0'
            http.use_ssl = true
            json = http.request(request)
            @result = JSON.parse(json.body)
          rescue => e
            @result = nil
            raise e
          end
        end

        def message(stock_name)
          return "Error" if @result == nil
          begin
            return "指定されたコードの銘柄が見つかりません．" if @result['chart']['error'] != nil

            close = [ @result['chart']['result'][0]['indicators']['quote'][0]['close'][0],\
                            @result['chart']['result'][0]['indicators']['quote'][0]['close'][1] \
                          ]
            index = ((close[1] == nil) ? 0:1)
            
            text = "今日の#{stock_name}\n" +
                   "始値 : #{@result['chart']['result'][0]['indicators']['quote'][0]['open'][index]}\n" +
                   "高値 : #{@result['chart']['result'][0]['indicators']['quote'][0]['high'][index]}\n" +
                   "安値 : #{@result['chart']['result'][0]['indicators']['quote'][0]['low'][index]}\n" +
                   "終値 : #{close[index]}\n\n" +
                   "前日比 : #{s=(d=close[index]-close[0])<0?"":"+"}#{d.round(2)} (#{s}#{(d/close[0]*100).round(2)}%)\n"
          rescue => e
            return "Error"
          end
        end
      end # class WorkHorse
      private_constant :WorkHorse
    end # class Stock
  end # module Command
end # module Swimmy
