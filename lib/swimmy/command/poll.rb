# coding: utf-8
#
# Hiromu Ishikawa / nomlab
# Yutaro Takaie / nomlab
# This is a part of https://github.com/nomlab/swimmy
#
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'uri'
require 'net/https'
require 'slack-ruby-bot'
require 'base'

$emoji_list = [[":one:",:one], [":two:",:two],[":three:",:three],[":four:",:four],[":five:",:five],[":six:",:six],[":seven:",:seven],[":eight:",:eight],[":nine:",:nine]]
$poll = {ts: 0, title: "", choices: [], count: []}

module Swimmy
  module Command
    class PollMatch < Swimmy::Command::Base
      command "poll" do |client, data, match|
        json = {:user_name => data.user, :text => data.text}.to_json
        params = JSON.parse(json, symbolize_names: true)
        res = Poll.new.response(params)
        text = JSON.parse(res)

        res = client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          text: text["text"]
        )
        $poll[:ts] = res.message.ts
        $poll[:choices].each_with_index do |choice, i|
          client.web_client.reactions_add(name: $emoji_list[i][1], channel: data.channel, timestamp: $poll[:ts])
        end
      end
      
      help do
        title "poll"
        desc "みんなからの投票を受付けます．"
        long_desc "poll question answer1,answer2,...\n" +
                  "questionは，みんなに聞きたい質問項目です．" +
                  "answer1やanswer2は，選択肢です．" +
                  "選択肢が複数ある場合は，半角コンマで区切ってください．" +
                  "選択肢は最大9つまで入力できます．"
      end
      
    end
    
    class PollCounter < SlackRubyBot::Server
      on 'reaction_added' do |client, data|
        p data
        if data.item.ts == $poll[:ts] and data.item_user != data.user
          reaction_idx = $emoji_list.index([(":"+data.reaction+":"), data.reaction.intern])
          $poll[:count][reaction_idx] += 1
          text = "「#{$poll[:title]}」について集計します!\n以下の選択肢に対応するスタンプを選択してください．\n"
          $poll[:choices].each_with_index do |choice, i|
            text += "#{$emoji_list[i][0]}：#{choice} #{$poll[:count][i]}\n"
          end
          client.web_client.chat_update(channel: data.item.channel, ts: $poll[:ts], text: text)
        end
      end

      on 'reaction_removed' do |client, data|
        p data
        if data.item.ts == $poll[:ts] and data.item_user != data.user
          reaction_idx = $emoji_list.index([(":"+data.reaction+":"), data.reaction.intern])
          $poll[:count][reaction_idx] -= 1
          text = "「#{$poll[:title]}」について集計します!\n以下の選択肢に対応するスタンプを選択してください．\n"
          $poll[:choices].each_with_index do |choice, i|
            text += "#{$emoji_list[i][0]}：#{choice} #{$poll[:count][i]}\n"
          end
          client.web_client.chat_update(channel: data.item.channel, ts: $poll[:ts], text: text)
        end
      end
    end
    
    class Poll
      def response(params, options = {})
        query_str = params[:text]
        query_str = query_str.match(/poll (.*) (.*)/)
        $poll[:title] = query_str[1]
        $poll[:choices] = query_str[2].split(",")
        $poll[:choices].each do |choice|
          $poll[:count].push(0)
        end
        res_text = "「#{$poll[:title]}」について集計します!\n以下の選択肢に対応するスタンプを選択してください．\n"
        $poll[:choices].each_with_index do |choice, i|
          res_text += "#{$emoji_list[i][0]}：#{choice} #{$poll[:count][i]}\n"
        end
        return {text: res_text}.merge(options).to_json
      end
    end
  end
end
