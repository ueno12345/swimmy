module Swimmy
  module Command
    class At < Swimmy::Command::Base
      @@occurences = []
      @@recurrences = []
      @@first_tick = true

      command "at" do |client, data, match|

        channel = data.channel
        user_name = client.web_client.users_info(user: data.user).user.real_name
        args = match[:expression]
        ss_controller = SpreadSheetController.new(spreadsheet)

        if args == "update"
            client.say(channel: data.channel, text: "実行するコマンドの情報を更新しています")
            begin
              @@recurrences = ss_controller.read # update recurrence
              client.say(channel: data.channel, text: "更新しました．")
            rescue
              client.say(channel: data.channel, text: "更新に失敗しました．")
            end
        else
          begin
            recurrence = Swimmy::Resource::Recurrence.from_slack(args, user_name, channel)
          rescue RuntimeError
            client.say(channel: data.channel, text: "無効な引数です．")
          else
            client.say(channel: data.channel, text: "予定を追加しています...")
            begin
              ss_controller.add(recurrence)
              client.say(channel: data.channel, text: "追加しました．")
              @@recurrences = ss_controller.read # update recurrence
            rescue
              client.say(channel: data.channel, text: "失敗しました．")
            end
          end
        end
      end

      help do |client, data|
        title "at"
        desc "指定した日時にコマンドを実行します．"
        long_desc "at [every <Interval>] <DateTime> do <Command>\n" +
          "[every <Interbal>] : この要素が指定された場合，コマンドを繰り返し実行します．\n" +
          "<Interval> : 繰り返しの間隔を以下の中から指定してください．\n" +
          "    ・day : 毎日\n" +
          "    ・week : 毎週\n" +
          "    ・month : 毎月\n" +
          "    ・year : 毎年\n" +
          "<DateTime> : コマンドを実行する日時を指定してください．" +
          "繰り返し実行の場合，この日時を起点に繰り返し実行が始まります．"
          "また \"at update\" でスプレッドシートの変更を即座に反映することができます．"
      end

      tick do |client, data|
        puts "at command..."

        now = Time.now

        if @@first_tick
          @@recurrences = SpreadSheetController.new(spreadsheet).read
          @@first_tick = false
        end

        for occurence in @@occurences
          if occurence.should_execute?(now)
            occurence.execute(client)
          end
        end

        @@occurences.clear

        for recurrence in @@recurrences
          begin
            occurence = Swimmy::Resource::Occurence.new(recurrence, now)
            @@occurences.append(occurence)
          rescue RuntimeError
            # occurence is expired
          end
        end
      end

      class SpreadSheetController
        def initialize(spreadsheet)
          @sheet = spreadsheet.sheet("recurrence", Swimmy::Resource::Recurrence)
        end

        def add(recurrence)
          @sheet.append_row(recurrence)
        end

        def read()
          return @sheet.fetch
        end
      end
    end
  end
end
