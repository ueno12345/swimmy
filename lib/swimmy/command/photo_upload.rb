# Ryota Nishi / nomlab
# This is a part of https://github.com/nomlab/swimmy

require 'json'
require 'uri'
require 'net/https'
require 'pp'

module Swimmy
  module Command
    class PhotoUploadBot < Base
      # https://console.developers.google.com/apis/dashboard
      # からダウンロードして置いておく
      GOOGLE_CREDENTIAL_APTH = "config/credentials.json"

      # swimmy/exe/google_photo_auth を実行することで
      # swimmy/config/google-photo-token.json が作成される
      GOOGLE_TOKEN_PATH = "config/google-photo-token.json"

      if File.exist?(GOOGLE_CREDENTIAL_APTH)
        credentials = JSON.load(File.open(GOOGLE_CREDENTIAL_APTH))
        CLIENT_ID = credentials["installed"]["client_id"]
        CLIENT_SECRET = credentials["installed"]["client_secret"]
      end

      on 'message' do |client, data|
        if data.files
          data.files.each do |file|
            next unless ["jpg", "png"].include?(file.filetype)
            client.say(channel: data.channel, text: "Google Photos にアップロード中 (#{file.name})...")

            Thread.new do
              begin
                blob = SlackFileDownloader.new(ENV["SLACK_API_TOKEN"]).fetch(file.url_private_download)
                url = GooglePhotosUploader.new(GOOGLE_TOKEN_PATH).upload(blob, file.name, data.text)
                client.say(channel: data.channel, text: "アップロード完了 #{url}")
              end
            end
          end
        end
      end # on message
    end # class PhotoUploadBot

    class GooglePhotosUploader
      def initialize(google_token_path)
        @access_token = update_token(google_token_path)
      end

      def upload(file, filename, comment)
        # 画像データをアップロード
        @upload_url = "https://photoslibrary.googleapis.com/v1/uploads"
        @mkmedia_url = "https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate"

        header =  {
          "Authorization" => "Bearer #{@access_token}",
          "Content-Type" => "application/octet-stream",
          "X-Goog-Upload-Protocol" => "raw",
          "X-Goog-Upload-File-Name" =>  filename
        }

        uri = URI.parse(@upload_url)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, file, header)
        end
        upload_token = res.body

        # メディアアイテムの作成
        header =  {
          "Authorization" => "Bearer #{@access_token}",
          "Content-Type" => "application/json"
        }
        req = {:newMediaItems => {:simpleMediaItem => {:uploadToken => upload_token}}}
        uri = URI.parse(@mkmedia_url)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, req.to_json, header)
        end

        result = JSON.parse(res.body)["newMediaItemResults"][0]

        if result["status"]["message"] == "OK"
          url = result["mediaItem"]["productUrl"]
          filename = result["mediaItem"]["filename"]
          "<#{url}|#{filename}>"
        else
          nil
        end
      end

      private

      def update_token(google_token_path)
        # refresh_token を用いて access_token を更新FIXME: 毎回
        # access_token の更新を行っている．有効期限を確認して更新する
        # かを判断したほうがよい．
        token = JSON.load(File.open(google_token_path))
        refresh_token =token ["refresh_token"]
        request = {:refresh_token => refresh_token,
                   :client_id => Swimmy::Command::PhotoUploadBot::CLIENT_ID,
                   :client_secret => Swimmy::Command::PhotoUploadBot::CLIENT_SECRET,
                   :grant_type => "refresh_token" }

        uri = URI.parse("https://www.googleapis.com/oauth2/v4/token")
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.post(uri.request_uri, request.to_json, {"Content-Type" => "application/json"})
        end
        access_token = JSON.parse(res.body)["access_token"]

        token["access_token"] = access_token
        File.open(google_token_path, "w") do |f|
          f.puts token.to_json
        end

        return access_token
      end
    end # class GooglePhotosUploader

    class SlackFileDownloader
      def initialize(api_token)
        @api_token = api_token
      end

      def fetch(url_private_download)
        uri = URI.parse(url_private_download)
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = "Bearer #{@api_token}"

        file = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.request(req)
        end

        return file.body
      end
    end # class SlackFileDownloader

  end # module Command
end # module Swimmy
