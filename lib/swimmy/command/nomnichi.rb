# coding: utf-8
#
# Yoshinari Nomura / nomlab
#
# This is a part of https://github.com/nomlab/swimmy
#
# nomnichi -- Nominate the next person who is expected to write
#             nomnichi article.
#

module Swimmy
  module Command
    class Nomnichi < Swimmy::Command::Base
      require "sheetq"
      command "nomnichi" do |client, data, match|
        # whos_next = true
        spreadsheet = Swimmy::Command.sheet_config.general.default_sheet_id
        msg = Sheetq::Command::Nomnichi.new(spreadsheet, true).message
        client.say(channel: data.channel, text: msg)
      end
    end
  end
end
