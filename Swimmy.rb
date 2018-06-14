# coding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'SlackBot'
require 'FBot'
require 'Amebot'
require 'TakaBot'
require 'SYBot' 

class Swimmy < SlackBot
  include FBot
  include Amebot
  include TakaBot
  include SYBot

  def say_respond(params, options = {})
    text = params[:text].match(/「(.*)」と言って/)

    return {text: text[1]}.merge(options).to_json
  end

  def help_respond(params, options = {})

    # Add help comments
    text = "
・「〇〇」と言って
・(移動手段)での(出発地点)から(到着地点)までの道
・〇〇の雨の状況
・get issue or make issue (t:title)[b:body]
・「飲食店の名前 地名/都市名/駅名など」の情報
    "

    return {text: text}.merge(options).to_json
  end
end

slackbot = Swimmy.new

set :environment, :production

get '/' do
  "SlackBot Server"
end

post '/slack' do
  content_type :json
    return nil if params[:user_name] == "slackbot" || params[:user_id] == "USLACKBOT"

  # Add match patarn
  if (params[:text] =~ /「.*」と言って/) then
    slackbot.say_respond(params, username: "swimmy")

  # FBot
  elsif (params[:text] =~ /.*での.*から.*までの道/) then
    slackbot.distance_respond(params, username: "swimmy")

  # Amebot
  elsif (params[:text] =~ /雨の状況/) then
    slackbot.rain_info(params,username: "swimmy")

  # SYBot
  elsif (params[:text] =~ /get issue/ || params[:text] =~ /make issue/) then
    slackbot.issue_respond(params, username: "swimmy")

  # TakaBot
  elsif (params[:text] =~ /の情報/) then
    slackbot.show_place_detail(params, username: "swimmy")

  else
    slackbot.help_respond(params, username: "swimmy")
  end
end

post '/webhook/git/issue' do
    #SYBot
    content_type :json
    slackbot.git_webhook_respond(params, username: "swimmy")
end
