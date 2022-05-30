# coding: utf-8
module Swimmy
  module Command
    class Whois < Swimmy::Command::Base
      
      command "whois" do |client, data, match|
        unless match[:expression]
          message = help_message
        else
          found_members = SearchInfo.new(spreadsheet).search(match[:expression])
          if found_members.empty?
            message = "#{match[:expression]}にマッチする人は居ませんでした．\n"
          else
           message = found_members.map{|m|   
             "ID: #{m.id}\n" +
               "Name: #{m.name}\n" +
               "Title: #{m.title}\n" +
               "Mail: #{m.mail}\n" +
               "Organization: #{m.organization}"
           }.join("\n")
          end
        end
        client.say(channel: data.channel, text: message)
      end

      help do
        title "whois"
        desc "キーワードから学生番号と氏名と学年とメールアドレスと所属を教えてくれる．"
        long_desc "whois <keyword>\n" +
                  "<keyword>で指定された研究室メンバの情報を教えます．\n\n"
      end

      ################################################################
      ### private inner class

      class SearchInfo
        require "sheetq"
        
        def initialize(spreadsheet)
          @spreadsheet = spreadsheet
        end

        def search(keyword)
          all_members = @spreadsheet.sheet("members", Swimmy::Resource::Member).fetch

          found_members = []
          
          all_members.each do |m|
            if m.match(keyword)
              found_members << m
            end
          end
          
          return found_members
        end
      end
      private_constant :SearchInfo
        
    end # class Whois
  end # module Command
end # module Swimmy
