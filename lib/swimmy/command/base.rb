# Usage:
#
# class YourCommand < Swimmy::Command::Base
#   match /hey (.*)/ do |client, data, match|
#     ...
#     spreadsheet...
#   end
#
#   command "wow" do |client, data, match|
#     ...
#     spreadsheet...
#   end
#
#   on "hello" do |client, data|
#     ...
#   end
# end
#

require "slack-ruby-bot"

module Swimmy
  module Command
    class << self
      attr_accessor :spreadsheet
    end

    class Base < SlackRubyBot::Commands::Base

      # You can use spreadsheet object in your command
      def self.spreadsheet
        Swimmy::Command.spreadsheet
      end

      # Create help_message for your command.
      # You can use in your command, for example:
      #   command "lottery" do |client, data, match|
      #     unless match[:expression]
      #       client.say(channel: data.channel, text: help_message)
      #     else
      #       ...
      def self.help_message(command_name = nil)
        command_name ||= command_name_from_class
        hlp = SlackRubyBot::Commands::Support::Help.instance.find_command_help_attrs(command_name)
        "#{command_name} - #{hlp.command_desc}\n\n#{hlp.command_long_desc}" if hlp
      end

      # You can Create periodic task by using tick.
      #   tick do |client, data|
      #     CHANNEL_LIST.each do |channel|
      #       client.say(channel: channel, text: "Hi!")
      #     end
      #   end
      def self.tick(&block)
        SlackRubyBot::Server.on("pong", &block)
      end

      # Can remove this in the future?
      #   Define hooks from within the bot instance #211
      #   https://github.com/slack-ruby/slack-ruby-bot/issues/211
      #
      def self.on(event_name, &block)
        SlackRubyBot::Server.on(event_name, &block)
      end
    end
  end
end
