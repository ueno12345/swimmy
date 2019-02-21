$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'slack-ruby-client'
require "open-uri"
require "json"
require 'dotenv'
Dotenv.load

post_channel = ENV['POST_CHANNEL']

Slack.configure do |conf|
  conf.token = ENV["SLACK_API_TOKEN"]
end

client = Slack::RealTime::Client.new

QIITA_URI = 'https://qiita.com/api/v2/items?page=1&per_page=5&query=stocks:>100'

Thread.new do
  client.on :hello do
    array = []
    loop do
      t = Time.new
      unless t.sunday? || t.saturday?
        if t.hour == 12 && t.min == 00
          article_str = open("#{QIITA_URI}", &:read)
          article = JSON.parse(article_str)
          url = ""
          if t.monday?
            array = []
          end

          count = 0
          article.each do |q|
            unless array.include?(q["id"])
              url += "#{q["url"]} \nいいね数 #{q["likes_count"]}\n"
              count += 1
              array.push(q["id"])
              if count == 3
                break
              end
            end
          end

          if url == ""
            client.message channel: post_channel, text: "トレンド記事はありません"
          else
            client.message channel: post_channel, text: "本日のおすすめ記事です!\n#{url}"
          end
        end
      else
        array = []
      end
      sleep 60
    end

  end

  client.on :closed do
    client.start!
  end

  client.start!
end
