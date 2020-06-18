module Swimmy
  module Command
    class Trivia < Swimmy::Command::Base

      QUIZ_URL = "https://opentdb.com/api.php?amount=1&category=18"
      POST_SCHEDULE = {}

      command "trivia" do |client, data, match|

        quiz = WorkHorse.new(QUIZ_URL)
        case match[:expression]
        when /(\d+):(\d+)/
          h,m = $1.to_i,$2.to_i
          unless 0 <= h && h <= 23 && 0 <= m && m <= 59
            client.say(channel: data.channel, text: "wrong time")
            break
          end

          now = Time.now
          alarm = Time.new(now.year, now.mon, now.day, h, m)
          alarm.next_day if alarm <= now

          POST_SCHEDULE[data.channel] = alarm
          client.say(channel: data.channel, text: "setup in #{data.channel} at #{h}:#{m}")

        when nil
          quiz.fetch
          client.say(channel: data.channel, text: quiz.message)

        when "off"
          POST_SCHEDULE.delete(data.channel)
          client.say(channel: data.channel, text: "delete schedule in #{data.channel}")

        when "help"
          client.say(channel: data.channel, text: help_message("trivia"))

        else
          client.say(channel: data.channel, text: "run \"trivia help\"")
        end
      end

      help do
        title "trivia"
        desc "クイズを出題します．"
        long_desc "trivia - すぐにクイズを出題します．\n" +
                  "trivia HH:MM - 毎日HH:MMに，このチャンネルにクイズを出題します． \n" +
                  "trivia off - クイズの出題をやめます．\n" +
                  "trivia help - ヘルプを表示します．\n"
      end

      tick do |client, data|
        now = Time.new
        quiz = WorkHorse.new(QUIZ_URL) 
        POST_SCHEDULE.each do |channel, time|
          if time <= now
            quiz.fetch
            client.say(channel: channel, text: quiz.message)

            POST_SCHEDULE[channel] = POST_SCHEDULE[channel].next_day
          end
        end
      end

      ####################################################################
      ### private inner class
      class WorkHorse
        require 'json'
        require 'uri'
        require 'net/http'


        def initialize(uri)
          @uri = uri
        end

        def fetch
          begin
            parsed_uri = URI.parse(@uri)
            json = Net::HTTP.get(parsed_uri)
            @result = JSON.parse(json)
          rescue => e
            @result = nil
            raise e
          end
        end

        def message
          return "error" if @result == nil

          text = <<~EOS
          Question :
          #{@result['results'][0]['question']}

          Answer :
          #{@result['results'][0]['correct_answer']}
          EOS
        end

      end # class WorkHorse
      private_constant :WorkHorse

    end # class Trivia
  end # module Command
end # module Swimmy

class Time
  def next_day
    self + (60 * 60 * 24)
  end
end
