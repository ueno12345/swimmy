# coding: utf-8
#
# Update swimmy system
#

module Swimmy
  module Command
    class Update < Swimmy::Command::Base

      command "update" do |client, data, match|
        client.say(channel: data.channel, text: "アップデートを開始します")

        begin
          system("git pull origin master && bundle install")

          if $?.success?
              client.say(channel: data.channel, text:"アップデートが完了しました．")
          else 
              client.say(channel: data.channel, text:"アップデートに失敗しました．")
          end
        end
      end


      help do
        title "update"
        desc "リモートリポジトリの変更内容をローカルブランチに取り込み，gemのインストールを行います．"
        long_desc "リモートリポジトリの変更内容をローカルブランチに取り込み，gemのインストールを行います．引数はいりません．"
      end

    end # class Update
  end # module Command
end # module Swimmy
