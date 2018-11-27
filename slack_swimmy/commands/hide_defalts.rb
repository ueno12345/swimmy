module Slack_swimmy
    module Commands
      class Unknown < SlackRubyBot::Commands::Base
        match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)
  
        def self.call(client, data, _match)
        end
      end
  
      class About < SlackRubyBot::Commands::Base
        command 'about', 'hi', 'help' do |client, data, match|
        end
      end
    end
  end