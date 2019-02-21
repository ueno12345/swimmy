# coding: utf-8
#
# Shutaro Yoshida / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'uri'
require 'net/https'
require 'slack-ruby-bot'
require 'base'

OWNER = "nomlab"
REPO = "sandbox"
ISSUE_URL = "https://api.github.com/repos/#{OWNER}/#{REPO}/issues"

module Swimmy
  module Command
    class Issue_operation_match < Swimmy::Command::Base
      match(/(todo: list|todo:\s*t\s*:\s*"(.*?)"\s*(\s*b\s*:\s*"(.*?)")?)/) do |client, data, match|
        json = {:user_name => data.user, :text => data.text}.to_json
        params = JSON.parse(json, symbolize_names: true)
        res = Issue_operation.new.issue_respond(params)
        text = JSON.parse(res)
        client.say(channel: data.channel, text: text["text"])
      end
    end

    class Issue_operation
      def issue_respond(params,options = {})
        return nil if params[:user_name] == "slackbot" || params[:user_id] == "USLACKBOT"
        text=params[:text]

        crud = issue_com_dic(text)

        case crud[0]
        when "r" then
          issue_list = get_issues
          if issue_list == nil then
            ret = {text: "There aren't any open issues."}.merge(options).to_json
          else
            err = issue_list.inspect
            if err !~ /title/
              puts err
              ret = {text: "API error"}.merge(options).to_json
              return ret
            end
            repository_url = issue_list[0]["repository_url"].gsub(/api.github.com\/repos/,"github.com")
            issues_url = repository_url << "\/issues"
            text_hedder = "\<" << issues_url << "\|\*Issues in #{OWNER}/#{REPO}\*\>\n"
            titles = text_hedder << "\n"

            issue_list.each do |issue|
              titles << ("\*Title: \*\<" << issue["html_url"])
              titles << ("\|" << issue["title"] << ">")
              titles << "\n"
            end
            ret =  {text: titles}.merge(options).to_json
          end

        when "c" then
          text = text.match(/todo:\s*t\s*:\s*"(.*?)"\s*(\s*b\s*:\s*"(.*?)")?/)
          new_issue = {:title => "default",:body => "Not edited yet \(created by Swimmy\)"}
          new_issue["title"] = text[1] unless text[1].nil?
          if text[3].nil? # create an issue with default body
            res = make_issue(new_issue)
          else 
            new_issue["body"] = text[3] 
            res = make_issue(new_issue)
          end
          title_url = make_link(res["html_url"], new_issue["title"])
          respond_text = "New issue created to #{OWNER}/#{REPO}! See here: #{title_url}"
          ret = {:text => respond_text}.merge(options).to_json

        else
          ret = {:text => "usage:\n \ntodo: list\ntodo: t:\"type title\" [b:\"type body (optional)\"]"}.merge(options).to_json
        end
        return ret
      end

      private
      def issue_com_dic(str)
        if (crud=str.match(/todo: list/)) != nil
          return ["r",0]
        elsif (i = str.index("todo: ")) != nil
          return ["c",i]
        else
          return "n"
        end
      end

      def get_issues
        ghtoken = ENV['GH_TOKEN']
        uri = URI.parse(ISSUE_URL)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "token #{ghtoken}"
        req_options = { use_ssl: uri.scheme == "https" }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        return JSON.parse(response.body)
      end

      def make_issue(issue)
        ghtoken = ENV['GH_TOKEN']
        uri = URI.parse(ISSUE_URL)
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "token #{ghtoken}"
        p request.body = issue.to_json
        req_options = { use_ssl: uri.scheme == "https" }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        res = JSON.parse(response.body)

        return res
      end

      def make_link(url,label)
        titles = "\<"
        titles << url << "\|" << label << "\>"
        return titles
      end

      def git_webhook_respond(payloads,options = {})
        params = JSON.parse(payloads[:payload])
        if (params == nil || params == {})then
          ret = {:text => "Faild to get action"}.merge(options).to_json
        else
          act = params["action"]
          repository_name = params["repository"]["name"] || "None"
          repository_url = params["repository"]["html_url"] || "None"
          issue_title = params["issue"]["title"] || "None"
          issue_url = params["issue"]["html_url"] || "None"
          issues_url = repository_url << "\/issues" || "None"
          user_name = params["issue"]["user"]["login"] || "None"
          assignee = params["issue"]["assignee"] || "None"
    
          text_hedder = "\<" << issues_url << "\|\*issues\*\>\n"
          ret_txt = text_hedder << "\n"
    
          case act
          when "opened" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって， \*issue\*\: "
            ret_txt << make_link(issue_url,issue_title) << "が作成されました．"
          when "reopened" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって， \*issue\*\:"
            ret_txt << make_link(issue_url,issue_title) << "が再び開かれました．"
          when "closed" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって， \*issue\*\:"
            ret_txt << make_link(issue_url,issue_title) << "が閉鎖されました．"
          when "assigned" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって，"
            ret_txt << user_name << "に \*issue\*\:"
            ret_txt << make_link(issue_url,issue_title) << "が割り当てられました．"
          when "unassigned" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって，"
            ret_txt << user_name << "が \*issue\*\:"
            ret_txt << make_link(issue_url,issue_title) << "の担当から外されました．"
          when "edited" then
            ret_txt = make_link(repository_url,repository_name) << "\:"
            ret_txt << user_name << "によって， \*issue\*\:"
            ret_txt << make_link(issue_url,issue_title) << "が編集されました．"
          else
            ret_txt = nil
          end
        end
        ret = {:text => ret_txt}.merge(options).to_json
        https_post(@slack_incoming_webhook,ret)
        return ret
      end
    
      def https_post(url,json_data)
        uri = URI.parse(url)
        request = Net::HTTP::Post.new(uri)
        request.body = json_data
        req_options = {use_ssl: uri.scheme == "https"}
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
      end 
    end
  end
end
