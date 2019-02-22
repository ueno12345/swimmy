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

      def self.on(event_name, &block)
        SlackRubyBot::Server.on(event_name, &block)
      end
    end
  end
end
