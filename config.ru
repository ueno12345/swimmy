$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'slack_swimmy'
require 'web'

Thread.abort_on_exception = true

Thread.new do
  begin
    Slack_swimmy::App.instance.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run Swimmy::Web
