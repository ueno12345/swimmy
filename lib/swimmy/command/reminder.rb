# coding: utf-8
#
# Yutaro Takaie / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'rexml/document'
require 'open-uri'
require 'nkf'
require 'pp'
require 'net/http'
require 'singleton'
require 'kconv'
require 'slack-ruby-bot'
require 'base'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'swimmy'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

module Swimmy
  module Command
    class Reminder_match < Swimmy::Command::Base
      match(/reminder:/) do |client, data, match|
        json = {:user_name => data.user, :text => data.text}.to_json
        p params = JSON.parse(json, symbolize_names: true)
        res = Reminder.new.insert_event(params)
        text = JSON.parse(res)
        client.say(channel: data.channel, text: text["text"])
      end
    end

    class Reminder
      private
      def authorize
        client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
        user_id = 'default'
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
          url = authorizer.get_authorization_url(base_url: OOB_URI)
          puts 'Open the following URL in the browser and enter the ' \
               "resulting code after authorization:\n" + url
          code = gets
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI
          )
        end
        credentials
      end

      public
      def insert_event(params,options = {})
        # Initialize the API
        service = Google::Apis::CalendarV3::CalendarService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = authorize
        
        query_str = params[:text]
        if query_str = query_str.match(/reminder: (.+) (\d{4}-\d{1,2}-\d{1,2}) ((?:[0-1][0-9]|[2][0-3]):[0-5][0-9])/) then
          event = Google::Apis::CalendarV3::Event.new({
            summary: query_str[1],
            start: {
              date_time: "#{query_str[2]}T#{query_str[3]}:00+09:00"
            },
            end: {
              date_time: "#{query_str[2]}T#{query_str[3]}:00+09:00"
            }
          })
          result = service.insert_event('2f3b9n4f8gs4cgricj79fdi9jg@group.calendar.google.com', event)

          res_text = "Reminder created. 「#{query_str[1]}」#{query_str[2]} #{query_str[3]}"
        else
          res_text = "Please 「reminder: summary yyyy-mm-dd 00:00」"
        end
        
        return {text: res_text}.merge(options).to_json
      end
    end
  end
end
