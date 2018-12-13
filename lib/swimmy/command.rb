module Swimmy
  module Command
    dir = File.dirname(__FILE__) + "/command"

    require "#{dir}/issue_operation"
    require "#{dir}/lunch_time"
    require "#{dir}/rain_information"
    require "#{dir}/restaurant_information"
    require "#{dir}/route"
  # require "#{dir}/hide_defalts"
  end
end
