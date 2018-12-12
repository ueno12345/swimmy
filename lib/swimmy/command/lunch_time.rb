$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dotenv'
Dotenv.load

require 'slack-ruby-client'

post_channel = ENV['POST_CHANNEL']

Slack.configure do |conf|
  conf.token = ENV["SLACK_API_TOKEN"]
end

client = Slack::RealTime::Client.new

Thread.new do
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
end