module Swimmy
  module Command
    class Keyword < Swimmy::Command::Base
      command "keyword" do |client,data,match|

	client.say(channel: data.channel, text:"合言葉を生成します．" )

    	url = URI.parse("https://randomuser.me/api/")

    	https = Net::HTTP.new(url.host, url.port)

    	https.use_ssl = true

    	req = Net::HTTP::Get.new(url.path)

    	res = https.request(req)

	begin
    	  hash = JSON.parse(res.body)
        rescue Exception => e
          client.say(channel: data.channel, text: "結果を取得できませんでした.")
          raise e
        end	

  	pass = hash["results"][0]["login"]["password"]

        client.say(channel: data.channel, text:"合言葉は「#{pass}」です．" )
      end
      
      help do
        title "keyword"
        desc "短いランダムな合言葉を発言します．"
        long_desc "短いランダムな合言葉を発言します．引数はありません．"
      end

     end
   end
 end
