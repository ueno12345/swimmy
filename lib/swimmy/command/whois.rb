# coding: utf-8
module Swimmy
  module Command
    class Whois < Swimmy::Command::Base
      
      command "whois" do |client, data, match|
        unless match[:expression]
          client.say(channel: data.channel, text: help_message)
        else
          result = Search.new(spreadsheet).check(match[:expression])
          message = result.join("\n")
          client.say(channel: data.channel, text: message)
        end
      end

      help do
        title "whois"
        desc "アカウント名から学生番号と氏名とメールアドレスを教えてくれる．"
        long_desc "whois account\n" +
                  "account で指定された研究室メンバの情報を教えます．\n\n"
      end

      ################################################################
      ### private inner class

      class Search
        require "sheetq"
        
        def initialize(spreadsheet)
          @spreadsheet = spreadsheet
        end

        def check(account_name)
          all_members = @spreadsheet.sheet("members", Swimmy::Resource::Member).fetch
          mem={}
          
          all_members.each do |m|
            mem[m.account] = [m.id,m.name,m.mail]
          end

          if 
            mem[account_name] == nil then ["#{account_name}はいませんでした．"]
          else
            mem[account_name]
          end
        end
      end
      private_constant :Search
        
    end # class Whois
  end # module Command
end # module Swimmy
