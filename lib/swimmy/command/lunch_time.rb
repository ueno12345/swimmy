module Swimmy
  module Command
    class LunchTime < Swimmy::Command::Base

      # per-channel post schedule
      POST_SCHEDULE = {}

      command "lunch_time" do |client, data, match|
        case match[:expression]
        when /(\d+):(\d+)/
          h, m = $1.to_i, $2.to_i
          unless 0 <= h && h <= 23 && 0 <= m && m <= 59
            client.say(channel: data.channel, text: "時刻の指定がおかしいです")
            break
          end

          now = Time.now
          nxt = Time.new(now.year, now.month, now.day, h, m)
          nxt += 86400 if nxt <= now
          POST_SCHEDULE[data.channel] = nxt
          client.say(channel: data.channel, text: "<##{data.channel}> に #{h}時#{m}分に通知します．")

        when "off"
          POST_SCHEDULE.delete(data.channel)
          client.say(channel: data.channel, text: "<##{data.channel}> には通知しません．")

        else
          client.say(channel: data.channel, text: help_message("lunch_time"))
        end
      end

      help do
        title "lunch_time"
        desc "ランチタイムだねって時にお知らせします．"
        long_desc "lunch_time HH:MM - 毎日平日 HH:MM 頃，このチャンネルに知らせます．\n" +
                  "lunch_time off お知らせをやめます．\n"
      end

      tick do |client, data|
        puts "Lunch Time..."
        now = Time.new

        POST_SCHEDULE.each do |channel, time|
          puts "Lunch Time #{channel} #{time}"

          if time <= now
            puts "Lunch Time Sending message..."

            # slide schedule to the next HH:MM
            POST_SCHEDULE[channel] += ((now - time).to_i / 86400 + 1) * 86400

            # break if now.sunday? || now.saturday?
            client.say(channel: channel, text: 'そろそろ，お昼ご飯の時間ですよ!!')
          end
        end
      end

    end # class LunchTime
  end # module Command
end # module Swimmy
