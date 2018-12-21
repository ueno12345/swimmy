require 'base'

module Swimmy
    module Command
      class Unknown < Swimmy::Command::Base
        match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)
        def self.call(client, data, _match)
        end
      end
  
      class About < Swimmy::Command::Base
        command 'about', 'hi', 'help' do |client, data, match|
        end
      end
    end
  end