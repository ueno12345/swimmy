# coding: utf-8
#
# Restart swimmy system
#

module Swimmy
  module Command
    class Restart < Swimmy::Command::Base

      command "restart" do |client, data, match|
        client.say(channel: data.channel, text: "再起動します")
          exe_file = File.expand_path($0)
          if File.exist?(exe_file)
            exec("bundle exec #{exe_file} --hello #{data.channel}:再起動完了!")
          else
            client.say(channel: data.channel, text: "再起動に失敗しました．")
          end
      end

      help do
        title "restart"
        desc "swimmyを再起動します．"
        long_desc "swimmyを再起動します．引数はありません．"
      end

    end # class Restart
  end # module Command
end # module Swimmy
