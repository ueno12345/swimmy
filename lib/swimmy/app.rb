#
# loop do
#   begin
#     bot = Swimmy::App.new(token: ENV["SLACK_API_TOKEN"])
#     bot.start!
#   rescue Exception => e
#     STDERR.puts "Error: #{e}"
#     STDERR.puts "wait 30 secs"
#     sleep 30
#   end
# end
#

require "celluloid"
require "slack-ruby-bot"

module Swimmy
  ## Ping thread to maintain connections
  ##  see https://github.com/slack-ruby/slack-ruby-bot/issues/107
  class Watchdog  < SlackRubyBot::Server
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

    def initialize(opt)
      if opt[:spreadsheet]
        Swimmy::Command.spreadsheet =
          initialize_spreadsheet(opt[:spreadsheet])
        opt.delete(:spreadsheet)
      end

      super(opt)
    end

    private

    def initialize_spreadsheet(spreadsheet_id)
      require "clian"
      require "sheetq"

      dir = "~/.config/sheetq/"

      config = Sheetq::Config.create_from_file(File.expand_path("config.yml", dir))

      client = Sheetq::GoogleClient.new(
        config.general.client_id,
        config.general.client_secret,
        File.expand_path("token_store.yml", dir),
        config.general.default_user
      )

      client.auth
      return Sheetq::Service::Spreadsheet.new(client, spreadsheet_id)
    end

  end # class App
end # module Swimmy
