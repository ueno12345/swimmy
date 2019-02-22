module Swimmy
  module Command
    class QiitaTrend < Swimmy::Command::Base

      # per-channel post schedule
      POST_SCHEDULE = {}
      QIITA_URI = 'https://qiita.com/api/v2/items?page=1&per_page=5&query=stocks:>100'

      command "qtrend" do |client, data, match|
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

        when "now"
          qiita = WorkHorse.new(QIITA_URI)
          qiita.fetch
          client.say(channel: data.channel, text: qiita.message)

        else
          client.say(channel: data.channel, text: help_message("qtrend"))
        end
      end

      help do
        title "qtrend"
        desc "Qiita トレンドを定期的にお知らせします．"
        long_desc "qtrend HH:MM - 毎日平日 HH:MM 頃，このチャンネルに知らせます．\n" +
                  "qtrend off - お知らせをやめます．\n" +
                  "qtrend now - 一度だけすぐに通知します．\n"
      end

      tick do |client, data|
        puts "Qiita Trend..."
        now = Time.new
        message = nil

        POST_SCHEDULE.each do |channel, time|
          puts "Qiita Trend Time #{channel} #{time}"

          if time <= now
            puts "Qiita Trend  Sending message..."
            # slide schedule to the next HH:MM
            POST_SCHEDULE[channel] += ((now - time).to_i / 86400 + 1) * 86400
            # break if now.sunday? || now.saturday?
            qiita = WorkHorse.new(QIITA_URI)
            qiita.fetch
            message ||= qiita.message
            client.say(channel: data.channel, text: message)
          end
        end
      end

      ################################################################
      ### private inner class

      class WorkHorse
        require "open-uri"
        require "json"

        def initialize(qiita_uri)
          @qiita_uri = qiita_uri
        end

        def fetch
          hash = {}
          JSON.parse(open(@qiita_uri, &:read)).each do |q|
            hash[q["id"]] = q
          end
          @articles = hash.values
        end

        def message(max_articles = 3)
          if @articles.empty?
            ""
          else
            @articles.sort {|a,b| b['likes_count'] <=> a['likes_count'] }
              .take(max_articles)
              .map {|q| "#{q['url']} (likes: #{q['likes_count']})"}.join("\n")
          end
        end
      end
      private_constant :WorkHorse

    end # class QiitaTrend
  end # module Command
end # module Swimmy
