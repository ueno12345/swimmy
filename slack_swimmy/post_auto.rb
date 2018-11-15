$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dotenv'
Dotenv.load

require 'yaml'
require 'slack-ruby-client'

config = YAML.load_file("settings.yml") if File.exist?("settings.yml")
post_channel = ENV['POST_CHANNEL'] || config["post_channel"]

Slack.configure do |conf|
  conf.token = ENV["SLACK_API_TOKEN"]
end

client = Slack::RealTime::Client.new

client.on :hello do
  loop do
    t = Time.new
    unless t.sunday? || t.saturday?
      if t.hour == 11 && t.min == 30
        client.message channel: post_channel, text: 'そろそろ，お昼ご飯の時間ですよ!!'
      end
    end
    sleep 60
  end
end

client.on :closed do
  client.start!
end

client.start!