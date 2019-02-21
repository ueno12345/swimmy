# coding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__))

module Swimmy
  module Command
    class Lottery_matcher < SlackRubyBot::Commands::Base
      match(/.*lottery.*/) do |client, data, match|
        array = match.to_s.partition(/参加者:/)
        participant = array[2].split(",")
        result = Lottery.new.exec(participant)
        client.say(channel: data.channel, text: "This message send by lottery.\nUsage: lottery 参加者:person1, person2, .. ,personN\nresult is #{result}")
      end
    end

    class Lottery
      def exec(participant)
        participant = get_members(participant)
        rank = participant.shuffle
        result = {}
        participant.each{ |person|
          result[person] = rank.index(person) + 1
        }
        return result
      end

      private

      #This func only move nomlab, but this func shoudl move GN, New, B4, M1, M2
      def get_members(participant)
        # This array shoud be made by google spread sheet
        nomlab = ["nom", "ishikawa", "suzuki", "tsubokawa", "ogura-i", "nishi", "yamamoto-e", "takaie", "takahashi", "fujiwara-yu", "yoshida-s"]
        participant.each{ |person|
          if person == "nomlab" then
            participant.delete(person)
            participant = participant + nomlab
          end
        }
        return participant
      end

    end# class Lottery
  end# module Command
end# module Swimmy
