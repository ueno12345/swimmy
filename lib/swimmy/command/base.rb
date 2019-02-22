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
      def self.spreadsheet
        Swimmy::Command.spreadsheet
      end

      def self.help_message(command_name = nil)
        command_name ||= command_name_from_class
        hlp = SlackRubyBot::Commands::Support::Help.instance.find_command_help_attrs(command_name)
        "#{command_name} - #{hlp.command_desc}\n\n#{hlp.command_long_desc}" if hlp
      end

      def self.on(event_name, &block)
        SlackRubyBot::Server.on(event_name, &block)
      end
    end
  end
end
