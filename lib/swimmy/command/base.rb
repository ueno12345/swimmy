require "slack-ruby-bot"

module Swimmy
  module Command
    def self.sheet_service
      @sheet_service
    end

    def self.sheet_config
      @sheet_config
    end

    class << self
      attr_writer :sheet_service, :sheet_config
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
