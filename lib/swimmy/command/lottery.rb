# coding: utf-8
module Swimmy
  module Command
    class Lottery < Swimmy::Command::Base

      command "lottery" do |client, data, match|
        unless match[:expression]
          client.say(channel: data.channel, text: help_message)
        else
          result = WorkHorse.new(spreadsheet).draw(match[:expression].split)
          message = result.map.with_index(1) {|m, i| "#{i} #{m}"}.join("\n")
          client.say(channel: data.channel, text: message)
        end
      end

      help do
        title "lottery"
        desc "クジ引きを作ってくれます．"
        long_desc "lottery name1 name2 ...\n" +
                  "name1, name2 で指定された参加者でくじ引きを行います．\n\n" +
                  "lottery %<keyword>\n" +
                  "以下の <keyword> で指定されたメンバーでくじ引きを行います．\n\n" +
                  "<keyword> (大文字と小文字は区別されません)\n" +
                  "・学年: B4, M1, M2\n" +
                  "・グループ: New, GN"
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
          all_members = spreadsheet.sheet("members", Swimmy::Resource::Member).fetch.select {|m| m.active? }
          members = []

          participants.each do |name|
            case name
            when /^%all$/
              members += all_members.map(&:name)

            when /^%(.*)/
              keyword = $1.downcase
              members += all_members.select {|m|
                m.team.split(/ *, */).map(&:downcase).include?(keyword) ||
                m.title.split(/ * /).map(&:downcase).include?(keyword)
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
