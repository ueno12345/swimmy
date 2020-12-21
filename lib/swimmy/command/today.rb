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
require 'active_support/time'

module Swimmy
  module Command
    class Today < Base      
      command "today" do |client, data, match|
        client.say(channel: data.channel, text: "予定を取得中...")

        begin
          message = "今日(#{Date.today.strftime("%m/%d")})の予定\n"
          message << GetEvents.new(spreadsheet).message
        rescue => e
          message = "予定の取得に失敗しました．"
        end
        
        client.say(channel: data.channel, text: message)
      end # command message

      help do
        title "today_event"
        desc "今日の予定を表示します．"
        long_desc "今日の予定を表示します．引数はいりません．"
      end # help message
    end # class Today

    
    class GetEvents
      require 'sheetq'
      attr_reader :spreadsheet
      
      OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
      SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

      def initialize(spreadsheet)
        @sheet = spreadsheet.sheet("calendar", Swimmy::Resource::Calendar)
        @service = Google::Apis::CalendarV3::CalendarService.new
        @service.client_options.application_name = "SWIMMY"
        @service.authorization = authorize
      end

      def message
        calendars = @sheet.fetch
        events = []
        message = ""
        calendars.each do |calendar|
          events.concat(get_event(calendar.id, calendar.name))
        end
        
        events = events.sort_by{|x| [x[0], x[1]]}
        message = "- 今日の予定はありません．\n" if events.empty?

        for time, summary, name in events
          message << "#{time}: #{summary}(#{name})\n"
        end

        return message
      end

      def get_event(calendar_id, calendar_name)
        events = []
          
        result = @service.list_events(
          calendar_id,
          single_events: true,
          time_min: DateTime.now.beginning_of_day.rfc3339,
          time_max: DateTime.now.end_of_day.rfc3339,
          order_by: "startTime"
        )
        
        result.items.each do |event|
          puts event.summary
          start = event.start.date || event.start.date_time
          events.push([start.strftime('%H:%M:%S'), event.summary, calendar_name])
        end
        puts events
        return events
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
