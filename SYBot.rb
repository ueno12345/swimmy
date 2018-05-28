# coding: utf-8
# Shutaro Yoshida / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'json'
require 'uri'
require 'yaml'
require 'net/https'

 GITHUB_API = "https://api.github.com/repos/nomlab/nompedia/issues"
 USERNAME = @config["USAERNAME"]
 PASSWORD = @config["PASSWORD"]

  module SYBot

  def issue_respond(params,options = {})
    return nil if params[:user_name] == "slackbot" || params[:user_id] == "USLACKBOT"
    text=params[:text]
    text.slice!(0..6)
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
        titles = "issues\n"

        issue_list.each do |issue|
          titles << ("title: " << issue["title"] )
          titles << "\n"
        end
        ret =  {text: titles}.merge(options).to_json
      end

    when "c" then
      new_issue = {:title => "default",:body => "default",:assignee => USERNAME}
      if (i1 = text.index("t:",crud[1] + "make issue".size)) != nil then
        if (i2 = text.index("b:",i1+2)) != nil then
          new_issue["title"] = text[i1+2...i2-1]
          new_issue["body"] = text[i2+2...-1]
          make_issue(new_issue)
          ret = {text: "created"}.merge(options).to_json
        else
          new_issue[title] = text[clud[1]...-1]
          err = make_issue(new_issue)
          if err == nil
            ret = {text: "created"}.merge(options).to_json
          else
            ret = {text: "creation faild:" + err}.merge(options).to_json
          end
        end

      else
        ret = {text: "make issue t:(title)[b:body]"}.merge(options).to_json
      end

    else
      ret = {text: "usage:\n \nget issue\nmake issue :t(title)[b:(body)]"}.merge(options).to_json
    end
    return ret
  end

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
    uri = URI.parse(GITHUB_API)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(USERNAME, PASSWORD)
    req_options = {use_ssl: uri.scheme == "https"}
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return JSON.parse(response.body)
  end

  def make_issue(issue)
    uri = URI.parse(GITHUB_API)
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(USERNAME, PASSWORD)
    request.body = issue.to_json
    req_options = {use_ssl: uri.scheme == "https"}
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return JSON.parse(response.body)["message"]
  end
end
