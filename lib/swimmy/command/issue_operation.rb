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

GITHUB_API = "https://api.github.com/repos/nomlab/nompedia/issues"

module Swimmy
  module Command
    class Issue_operation_match < Swimmy::Command::Base
      match(/(get|make) issue/) do |client, data, match|
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

        git_username = ENV['GIT_USERNAME']
        git_password = ENV['GIT_PASSWORD']
        # text.slice!(0..6)
        crud = issue_com_dic(text)

        case crud[0]
        when "r" then
          issue_list = get_issues
          if issue_list==nil then
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
            text_hedder = "\<" << issues_url << "\|\*issues\*\>\n"
            titles = text_hedder << "\n"

            issue_list.each do |issue|
              titles << ("\*Title: \*\<" << issue["html_url"])
              titles << ("\|" << issue["title"] << ">")
              titles << "\n"
            end
            ret =  {text: titles}.merge(options).to_json
          end

        when "c" then
          new_issue = {:title => "default",:body => "Not edited yet\(created by Swimmy\)",:assignee => git_username}
          if (i1 = text.index("t:",crud[1] + "make issue".size)) != nil then
            if (i2 = text.index("b:",i1+2)) != nil then
              new_issue["title"] = text[i1+2...i2-1]
              new_issue["body"] = text[i2+2...-1]
              make_issue(new_issue)
              ret = {:text => "created"}.merge(options).to_json
            else
              new_issue["title"] = text[i1+2...-1]
              err = make_issue(new_issue)
              if err == nil
                ret = {:text => "created"}.merge(options).to_json
              else
                ret = {:text => ("creation faild:" + err)}.merge(options).to_json
              end
            end

          else
            ret = {:text => "make issue t:(title)[b:body]"}.merge(options).to_json
          end

        else
          ret = {:text => "usage:\n \nget issue\nmake issue :t(title)[b:(body)]"}.merge(options).to_json
        end
        return ret
      end

      private
      def issue_com_dic(str)
        if (crud=str.match(/get issue/)) != nil
          return ["r",0]
        elsif (i = str.index("make issue")) != nil
          return ["c",i]
        else
          return "n"
        end
      end

      def get_issues
        git_username = ENV['GIT_USERNAME']
        git_password = ENV['GIT_PASSWORD'] 
        uri = URI.parse(GITHUB_API)
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(git_username, git_password)
        req_options = {use_ssl: uri.scheme == "https"}
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        return JSON.parse(response.body)
      end

      def make_issue(issue)
        git_username = ENV['GIT_USERNAME']
        git_password = ENV['GIT_PASSWORD'] 
        uri = URI.parse(GITHUB_API)
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(git_username, git_password)
        request.body = issue.to_json
        req_options = {use_ssl: uri.scheme == "https"}
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        return JSON.parse(response.body)["message"]
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
