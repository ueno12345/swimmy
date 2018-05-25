# coding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'SlackBot'
require 'FBot'

class Swimmy < SlackBot
  include FBot
  def help_respond(params, options = {})
    # Add help comments
    text = "「〇〇」と言って or (移動手段)での(出発地点)から(到着地点)までの道"
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
  elsif (params[:text] =~ /.*での.*から.*までの道/) then
    # FBot
    slackbot.distance_respond(params, username: "swimmy")

    # elsif
    # elsif
    # elsif
  
  else
    slackbot.help_respond(params, username: "swimmy")
  end
end


