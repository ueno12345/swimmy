# coding: utf-8
#
# Update swimmy system
#
require 'systemu'

module Swimmy
  module Command
    class Update < Swimmy::Command::Base

      command "update" do |client, data, match|
        client.say(channel: data.channel, text: "アップデートを開始します")

        system('git fetch && [ $(git log --oneline origin/master -1 --pretty=format:"%h") = $(git log -1 --pretty=format:"%h") ]')
        if $?.success?
          client.say(channel: data.channel, text:"最新の状態です")
        else
          status, stdout, stderr = systemu("git merge --ff-only origin master && bundle install")

          if status.success?
            client.say(channel: data.channel, text:"アップデートが完了しました．")
          else
            text = <<-"EOS"
            {
            アップデートに失敗しました．www"
             ---------------------------------------
             "#{stderr}"
             ---------------------------------------
            }
            EOS
            client.say(channel: data.channel, text:text)
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
