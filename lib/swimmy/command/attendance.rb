# coding: utf-8
#
# Keep track of members' attendance
#
module Swimmy
  module Command
    class Attendance < Swimmy::Command::Base
      command 'hi', 'bye' do |client, data, match|

        cmd = match[:command]
        now = Time.now
        usr = client.web_client.users_info(user: data.user).user.real_name

        client.say(channel: data.channel, text: "記録中: #{now.strftime('%Y-%m-%d %H:%M:%S')} #{cmd} #{usr}...")

        begin
          AttendanceLogger.new(spreadsheet).log(now, cmd, usr, "")
        rescue Exception => e
          client.say(channel: data.channel, text: "履歴を記録できませんでした.")
          raise e
        end

        client.say(channel: data.channel, text: "履歴を記録しました．")
      end

      help do
        title "attendance"
        desc "hi/bye で入退室をスプレッドシートに記録します"
        long_desc "attendance (hi|bye)\n" +
                  "もしくは，メンションで hi/bye だけでも OK です．"
      end

      ################################################################
      ## private inner class

      class AttendanceLogger
        def initialize(spreadsheet)
          @sheet = spreadsheet.sheet("attendance", Swimmy::Resource::Attendance)
        end

        def log(time, inout, user_name, comment = nil)
          attendance = Swimmy::Resource::Attendance.new(time, inout, user_name, comment)
          @sheet.append_row(attendance)
        end
      end
      private_constant :AttendanceLogger

    end # class Attendance
  end # module Command
end # module Swimmy
