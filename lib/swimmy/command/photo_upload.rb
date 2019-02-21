# coding: utf-8
# Ryota Nishi / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'slack-ruby-bot'
require 'base'
require 'json'
require 'uri'
require 'net/https'

# swimmy/exe/google_photo_auth を実行することで swimmy/config/google-photo-token.json が作成される
TOKEN_FILE_PATH = "config/google-photo-token.json"

credentials = JSON.load(File.open("config/credentials.json"))

CLIENT_ID = credentials["installed"]["client_id"]
CLIENT_SECRET = credentials["installed"]["client_secret"]

module Swimmy
  module Command
    class PhotoUploadBot < SlackRubyBot::Server
      # file_shared イベントが発生すると処理を実行
      on 'file_shared' do |client, data|
        # refresh_token を用いて access_token を更新
        # FIXME: 毎回 access_token の更新を行っている．有効期限を確認して更新するかを判断したほうがよい．
        token = JSON.load(File.open(TOKEN_FILE_PATH))
        refresh_token =token ["refresh_token"]
        request = { :refresh_token => refresh_token, :client_id => CLIENT_ID, :client_secret => CLIENT_SECRET, :grant_type => "refresh_token" }
        uri = URI.parse("https://www.googleapis.com/oauth2/v4/token")
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, request.to_json, { "Content-Type" => "application/json" })
        end
        access_token = JSON.parse(res.body)["access_token"]
        token["access_token"] = access_token
        File.open("config/google-photo-token.json", "w") do |f| 
          f.puts token.to_json
        end

        # Slack から画像をダウンロードし，GooglePhoto にアップロード
        Thread.new do
          filename, file = SlackFileDownloader.new(ENV['SLACK_API_TOKEN']).download(data.file_id)
          if file != nil
            result = GooglePhotoUploader.new(access_token).upload(file, filename)

            # 結果の送信
            if result["status"]["message"] == "OK"
              url = result["mediaItem"]["productUrl"]
              filename = result["mediaItem"]["filename"]
              client.say(channel: data.channel_id, text: "Successfully uploaded: <#{url}|#{filename}>")
            else
              client.say(channel: data.channel_id, text: "Failed to upload image.")
            end
          end
        end
      end
    end

    class SlackFileDownloader
      def initialize(slack_token)
        @base_url = "https://slack.com/api/files.info"
        @token = slack_token
        @allow_filetype = ["jpg", "png"]
      end

      def download(file_id)
        # file_id からファイルの情報を取得
        url = URI.parse(@base_url + "?token=" + @token + "&file=" + file_id)
        res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.get(url)
        end
        file_info = JSON.parse(res.body)

        # 上で取得した res に含まれる url_private の URL からファイルをダウンロード
        if @allow_filetype.include?(file_info["file"]["filetype"])
          file_url = URI.parse(file_info["file"]["url_private"])
          filename = file_info["file"]["name"]
          req = Net::HTTP::Get.new(file_url.request_uri)
          req['Authorization'] = "Bearer #{@token}"
          file = Net::HTTP.start(file_url.host, file_url.port, use_ssl: true) do |http|
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            http.request(req)
          end
          
          return filename, file.body
        else
          # filetype が "jpg"，"png"以外なら nilを返す
          return nil, nil
        end
      end
    end

    class GooglePhotoUploader
      def initialize(access_token)
        @token = access_token
        @upload_url = "https://photoslibrary.googleapis.com/v1/uploads"
        @mkmedia_url = "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate"
      end

      ## GooglePhoto へのアップロードには2段階の処理が必要
      #  1. @upload_url に画像データを POST
      #  2. 1のレスポンスに含まれる upload_token を使用して，メディアアイテムの作成を行う
      def upload(file, filename)
        # 画像データをアップロード
        header =  {  "Authorization" => "Bearer #{@token}", "Content-Type" => "application/octet-stream", "X-Goog-Upload-Protocol" => "raw", "X-Goog-Upload-File-Name" =>  filename }
        uri = URI.parse(@upload_url)        
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, file, header)
        end
        upload_token = res.body

        # メディアアイテムの作成
        header =  {  "Authorization" => "Bearer #{@token}", "Content-Type" => "application/json" }
        req = { :newMediaItems => { :simpleMediaItem => { :uploadToken => upload_token } }}
        uri = URI.parse(@mkmedia_url)        
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, req.to_json, header)
        end

        return JSON.parse(res.body)["newMediaItemResults"][0]
      end
    end
  end
end
