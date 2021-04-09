# coding: utf-8
module Swimmy
  module Command
    class Now < Swimmy::Command::Base

      command "now","117" do |client, data, match|
        client.say(channel: data.channel, text: TimeSignalFormatter.new.format(Time.now))  
      end
    
      help do
        title "now"
        desc "現在の日時についての様々な情報を発言します"
        long_desc "現在の日時についての情報（日付，時刻，和暦，第n曜日,記念日）を発言します．引数はありません"
      end

      ################################################################
      ## private inner class

      class TimeSignalFormatter
        DAYS = ["日","月","火","水","木","金","土"]
        OFFSET_LATEST_ERA = 2018
        LATEST_ERA = "令和"
        NOT_EXIST_ANNIVERSARIES = "記念日なし"

        def format(time)

          wday = DAYS[time.wday]
          wareki = time.year - OFFSET_LATEST_ERA
          anniversaries = anniversary_service.get_anniversay_event_titles_by_time(time)

          anniversaries_text = anniversaries.empty? ? NOT_EXIST_ANNIVERSARIES : anniversaries.join('，')

          message = "---------------時報---------------\n" +
                    time.strftime("%Y年%m月%d日（#{wday}）\n") +
                    time.strftime("%H時%M分\n") +
                    "\n" +
                    "今年は#{LATEST_ERA}#{wareki}年\n" +
                    "今日は第#{num_of_wday(time)}#{wday}曜日\n" + 
                    "\n" +
                    "今日の記念日：#{anniversaries_text}\n" +
                    "----------------------------------\n"

          message
        end

        def num_of_wday(time)
          time.day / DAYS.length + 1
        end

        def anniversary_service
          Service::Anniversary.new
        end

      end

    end # class Now

  end # module Command
end # module Swimmy
