# coding: utf-8
require 'json'
require 'uri'
require 'yaml'
require 'net/https'

class SlackBot
  def initialize(settings_file_path = "settings.yml")
    @config = YAML.load_file(settings_file_path) if File.exist?(settings_file_path)
  end

  def naive_respond(params, options = {})
    return nil if params[:user_name] == "slackbot" || params[:user_id] == "USLACKBOT"

    user_name = params[:user_name] ? "@#{params[:user_name]}" : ""
    return {text: "#{user_name} Hi!"}.merge(options).to_json
  end
end
