require "slack-ruby-bot"

module Swimmy
  module Command
    def self.sheet_service
      @sheet_service
    end

    class << self
      attr_writer :sheet_service
    end

    #
    # class YourCommand < Swimmy::Command::Base
    #   match /hey (.*)/ do |client, data, match|
    #     ...
    #   end
    # end
    #
    class Base < SlackRubyBot::Commands::Base
    end
  end
end
