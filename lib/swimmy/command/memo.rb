# coding: utf-8
#
# Save memo
#
module Swimmy
  module Command
    class Memo < Swimmy::Command::Base
      command "memo" do |client, data, match|

        now = Time.now
        usr = client.web_client.users_info(user: data.user).user.real_name
        if match[:expression]
          client.say(channel: data.channel, text: "メモを記録中: #{now.strftime('%Y-%m-%d %H:%M:%S')} #{usr}...")
          begin
            MemoLogger.new(spreadsheet).log(now, usr, match[:expression])
          rescue Exception => e
            client.say(channel: data.channel, text: "メモを記録できませんでした.")
            raise e
          end
          client.say(channel: data.channel, text: "メモを記録しました．\n内容: #{match[:expression]}")
        else
          client.say(channel: data.channel, text: "#{usr}さんのメモを表示します．")
          begin
          comments = MemoLogger.new(spreadsheet).show(usr)
          rescue Exception => e
            client.say(channel: data.channel, text: "メモを表示できませんでした.")
            raise e
          end
          client.say(channel: data.channel, text: "#{comments}")
        end 
      end

      help do
        title "memo"
        desc "メモを記録，および表示します"
        long_desc "memo ・・・ 発言者が今までに記録したメモを全件表示します．\n" +
          "memo comment・・・スプレッドシートにメモを記録します．comment は，記録するメモの内容です．"
      end

      ################################################################
      ## private inner class

      class MemoLogger
        def initialize(spreadsheet)
          @sheet = spreadsheet.sheet("memo", Swimmy::Resource::Memo)
        end

        def log(time, user_name, comment)
          memo = Swimmy::Resource::Memo.new(time, user_name, comment)
          @sheet.append_row(memo)
        end
        
        def show(user_name)
          comments = []
          for row in @sheet.fetch
            if row.member_name == user_name
              comments.append("#{row.time} #{row.comment}\n")
            end
          end
          return comments.join
        end
      end
      private_constant :MemoLogger

    end # class Memo
  end # module Command
end # module Swimmy
