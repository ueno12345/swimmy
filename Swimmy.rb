# coding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'SlackBot'
require 'FBot'
require 'Amebot'

class Swimmy < SlackBot
  include FBot
  include Amebot
  def help_respond(params, options = {})
    # Add help comments

    text = "
・「〇〇」と言って\n
・(移動手段)での(出発地点)から(到着地点)までの道\n
・〇〇の雨の状況\n
・get issue or make issue (t:title)[b:body]\n"

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
    slackbot.issue_respond(params, username: "SYBot")

    # elsif
    # elsif
    # elsif

  else
    slackbot.help_respond(params, username: "swimmy")
  end
end
