require 'celluloid'
require 'slack-ruby-bot'

##
## loop do
##   begin
##     bot = Swimmy::App.new(token: ENV["SLACK_API_TOKEN"])
##     bot.start!
##   rescue Exception => e
##     STDERR.puts "Error: #{e}"
##     STDERR.puts "wait 30 secs"
##     sleep 30
##   end
## end
##
module Swimmy
  SlackRubyBot.configure do |config|
    config.send_gifs = false
  end

  ## Ping thread to maintain connections
  ##  see https://github.com/slack-ruby/slack-ruby-bot/issues/107
  class PingThread  < SlackRubyBot::Server
    extend Celluloid

    PONG_ID_QUEUE = []

    def self.pong_received?(id)
      !PONG_ID_QUEUE.delete(id).nil?
    end

    on "hello" do |client, data|
      PONG_ID_QUEUE.clear
      @reconnect_count ||= 0

      if @timer
        @timer.cancel
        @reconnect_count += 1
      end

      sequence = 1

      @timer = every 30 do
        client.ping({id: sequence})
        puts "ping #{sequence}, reconnect: #{@reconnect_count}."
        sleep 3
        raise Errno::ETIMEDOUT unless pong_received?(sequence)
        sequence += 1
      end
    end

    on "pong" do |client, data|
      sequence = data[:reply_to].to_i
      puts "pong #{sequence}"
      PONG_ID_QUEUE << sequence
    end
  end

  ## Main app
  class App < SlackRubyBot::Server
  end
end
