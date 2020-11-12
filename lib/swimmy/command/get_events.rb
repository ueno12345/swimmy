# coding: utf-8
# This is a part of https://github.com/nomlab/swimmy

require 'json'
require 'uri'
require 'net/https'
require 'pp'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'
require 'yaml'
require 'active_support/time'

module Swimmy
  module Command
    class SayEventsBot < Base
      set = YAML.load_file('settings.yaml')
      calendars = set["calendar_list"]
      
      command "today_event" do |client, data, match|
        client.say(channel: data.channel, text: "予定を取得中...")
        message = "今日(#{Date.today.strftime("%m/%d")})の予定\n"
        calendars.each do |calendar|
          message << calendar["name"] << "\n"
          calendar_id = calendar["calendar_id"]
          begin
            result = GetEvents.new().get(calendar_id)
            message << result << "\n\n"
          rescue Exception => e
            message << "- 予定を取得できませんでした." << "\n\n"
          end
        end
        client.say(channel: data.channel, text: message)
      end # command message

      help do
        title "today_event"
        desc "今日の予定を表示します．"
        long_desc "今日の予定を表示します．引数はいりません．"
      end # help message
 
    end # class SayEventsBot

    class GetEvents
      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

      def initialize()
        @service = Google::Apis::CalendarV3::CalendarService.new
        @service.client_options.application_name = "SWIMMY"
        @service.authorization = authorize
      end

      def get(calendar_id)
        msg = ""
        result = @service.list_events(
          calendar_id,
          single_events: true,
          time_min: DateTime.now.beginning_of_day.rfc3339,
          time_max: DateTime.now.end_of_day.rfc3339,
          order_by: "startTime"
        )
        
        msg << "- 予定なし" if result.items.empty?
        result.items.each do |event|
          start = event.start.date || event.start.date_time
          msg << "#{start.strftime('%H:%M:%S')}: #{event.summary}\n"
        end
        
        return msg
      end
      
      private
      
      def authorize
        # https://console.developers.google.com/apis/dashboard
        # からダウンロードして置いておく
        client_id = Google::Auth::ClientId.from_file "config/credentials.json"

        # OAuth 認証を通したトークンの保存先
        token_store = Google::Auth::Stores::FileTokenStore.new file: "config/google-calendar-token.yaml"
        authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
        user_id = "default"
        credentials = authorizer.get_credentials user_id

        # credentials がなければ OAuth 認証を実行
        # 他にも OAuth 認証を行うコマンドがあるため一箇所に統一したい
        if credentials.nil?
          url = authorizer.get_authorization_url base_url: OOB_URI
          puts "Open the following URL in the browser and enter the " \
               "resulting code after authorization:\n" + url
          code = gets
          credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI
          )
        end
        credentials
      end
    end
  end # module Command
end # module Swimmy
