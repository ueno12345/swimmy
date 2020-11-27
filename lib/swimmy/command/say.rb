require 'date'


module Swimmy
  module Command
    class Say < Swimmy::Command::Base
      POST_SCHEDULE = []

      command "say" do |client, data, match|
        arg = match[:expression].split(' ', 2)
        if arg.size == 2 then

          now = DateTime.now
          date = DateTime.parse(DateTime.parse(arg[0]).strftime("%Y%m%dT%H:%M:%S") + DateTime.now.zone) rescue false

          if ! date then
            client.say(channel: data.channel, text: "時刻の指定がおかしいです")
            break
          elsif date <= now then
            client.say(channel: data.channel, text: "未来の時間を指定してください")
            break
          else
            POST_SCHEDULE.append({date: date, text: arg[1], channel: data.channel})
            client.say(channel: data.channel, text: "<##{data.channel}> に #{date}に通知します．")
          end

        else
          client.say(channel: data.channel, text: help_message("say"))
        end
      end

      help do
        title "say"
        desc "指定の時間に指定された文字列を発言します．"
        long_desc "say <時間> <文字列> - <時間> 頃，このチャンネルに<文字列>と発言します．\n"
      end

      tick do |client, data|
        puts "say command..."
        now = DateTime.now

        POST_SCHEDULE.delete_if do |elem|
          p (elem[:date])
          p (elem[:channel]) 
          p (elem[:text])
          if elem[:date] <= now
            puts "Say command Sending message..."

            client.say(channel: elem[:channel], text: elem[:text])
            true
          else
            false
          end
        end
      end

    end # class Say
  end # module Command
end # module Swimmy

