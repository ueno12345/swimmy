# coding: utf-8

require "date"
require "json"
require "open-uri"

module Swimmy
  module Command
    class Tide < Swimmy::Command::Base
      
      command "tide" do |client, data, match|
        client.say(channel: data.channel, text: TideDataMessage.new.create_mes(match[:expression]))
      end #end "command"

      help do
        title "tide"
        desc "牛窓の潮の情報を教えます"
        long_desc "tide - 今日の牛窓の潮の情報を教えます\n" +
                  "tide YYYY-MM-DD - YYYY年MM月DD日の牛窓の潮の情報を教えます\n" +
                  "tide MM-DD - #{Date.today.year}年MM月DD日の牛窓の潮の情報を教えます\n"
      end #end "help"

      class TideDataMessage

        def parse2date(date_string)
          return Date.today unless date_string
          if date_string =~ /(\d+)-(\d+)(-(\d+))?/
            y, m, d = [$1, $2, $4].map(&:to_i) if $4
            y, m, d = [Date.today.year, $1, $2].map(&:to_i) unless $4
            return Date.new(y, m, d) if Date.valid_date?(y, m, d)
          end
          return nil
        end #end "parse2date"

        def parse2time(time_string)
          h, m = time_string.split(":").map(&:to_i)
          time = Time.new(1, 1, 1, h, m, 0)
        end #end "parse2time"

        def parse2str(time_ary)
          time_ary.map{|t| t.strftime("%H:%M")}.join(", ")
        end #end "parse2str"
        
        def calc_maxsp_time(edd_time, fl_time)
          time = (edd_time + fl_time).sort
          time.each_cons(2).map do |edd, fl|
            t = (edd - fl) / 2
            fl + t
          end
        end #end "calc_maxsp_time"

        def fetch_tide_data(date)
          tide_url = "https://tide736.net/api/get_tide.php?pc=33&hc=3&yr=#{date.year}&mn=#{date.mon}&dy=#{date.mday}&rg=day"
          
          data = JSON.parse(URI.open(tide_url).string)
          date = date.strftime("%Y-%m-%d")
          
          harbor = data["tide"]["port"]["harbor_namej"]
          type = data["tide"]["chart"][date]["moon"]["title"]
          
          edd_1 = data["tide"]["chart"][date]["edd"].first["time"]
          edd_2 = data["tide"]["chart"][date]["edd"].last["time"]
          flood_1 = data["tide"]["chart"][date]["flood"].first["time"]
          flood_2 = data["tide"]["chart"][date]["flood"].last["time"]

          edd = [parse2time(edd_1), parse2time(edd_2)].uniq
          flood = [parse2time(flood_1), parse2time(flood_2)].uniq
          
          maxsp = calc_maxsp_time(edd, flood)
          
          return harbor, type, edd, flood, maxsp
        end #end "fetch_tide_data"

        def create_mes(input)
          date = parse2date(input)
          return "Wrong format: #{input}" unless date
          
          harbor, type, edd, flood, maxsp = fetch_tide_data(date)

          mes = date.strftime("%Y-%m-%d") + "\n" +
                harbor + "\n" +
                "潮名 | " + type + "\n" +
                "干潮 | " + parse2str(edd) + "\n" +
                "満潮 | " + parse2str(flood) + "\n" +
                "最高潮流時 | " + parse2str(maxsp) + "\n"
          return mes
        end #end "create_mes"
      end #end "TideDataMessage"
    end #end "Tide"
  end #end "Command"
end #end "Swimmy"
