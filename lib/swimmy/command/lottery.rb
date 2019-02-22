module Swimmy
  module Command
    class Lottery < Swimmy::Command::Base

      command "lottery" do |client, data, match|
        unless match[:expression]
          client.say(channel: data.channel, text: help_message)
          return
        end
        result = WorkHorse.new(spreadsheet).draw(match[:expression].split)
        message = result.map.with_index(1) {|m, i| "#{i} #{m}"}.join("\n")
        client.say(channel: data.channel, text: message)
      end

      help do
        title "lottery"
        desc "クジ引きを作ってくれます．"
        long_desc "lottery name1 name2 ...\n" +
                  "name1, name2 は，参加者名もしくはグループ名です．" +
                  "グループ名には，%gn のように % で始めて下さい．" +
                  "全員を表すグループは，%all です．"
      end

      ################################################################
      ### private inner class

      class WorkHorse
        require "sheetq"
        attr_reader :spreadsheet

        def initialize(spreadsheet)
          @spreadsheet = spreadsheet
        end

        def draw(participants)
          all_members = spreadsheet.sheet("members", Sheetq::Resource::Member).fetch.select {|m| m.active? }
          members = []

          participants.each do |name|
            case name
            when /^%all$/
              members += all_members.map(&:name)

            when /^%(.*)/
              team = $1.downcase
              members += all_members.select {|m|
                m.team.split(/ *, */).map(&:downcase).include?(team)
              }.map(&:name)
            else
              members << name
            end
          end
          members.uniq.shuffle
        end
      end
      private_constant :WorkHorse

    end # class Lottery
  end # module Command
end # module Swimmy
