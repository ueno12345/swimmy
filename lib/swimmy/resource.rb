module Swimmy
  module Resource
    dir = File.dirname(__FILE__) + "/resource"

    autoload :Memo,        "#{dir}/memo.rb"
    autoload :Attendance,  "#{dir}/attendance.rb"
    autoload :Place,       "#{dir}/place.rb"
    autoload :Weather,     "#{dir}/weather.rb"
    autoload :Member,      "#{dir}/member.rb"
    autoload :Calendar,    "#{dir}/calendar.rb"
    autoload :Anniversary, "#{dir}/anniversary.rb"
    autoload :Recurrence,  "#{dir}/at.rb"
    autoload :Occurence,   "#{dir}/at.rb"
  end
end
