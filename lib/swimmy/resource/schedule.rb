require 'time'
require 'enumdate'

module Swimmy
  module Resource
    class Recurrence
      attr_reader :command, :channel, :start_time, :interval, :status

      def initialize(command, user_name, channel, start_time, interval, status)
        @command = command
        @user_name = user_name
        @channel = channel
        @start_time ||= begin
            Time.parse(start_time)
          rescue
            Time.now
          end
        @interval = Interval::from_string(interval)
        @status ||=
          if status == "true"
            true
          else
            false
          end
      end

      def self.from_slack(s, user_name, channel)

        if s == nil
          raise RuntimeError
        end
        match_data = s.match(/(every (day|weekday|week|month|year) )*(.+) do (.+)/)

        if (match_data == nil) || (match_data[4] == nil)
          raise RuntimeError
        end

        command = match_data[4]
        user_name = user_name
        channel = channel
        start_time = match_data[3]
        interval = match_data[2]
        status = "true"

        self.new(command, user_name, channel, start_time, interval, status)
      end

      def to_a
        [@command, @user_name, @channel, @start_time.to_s, @interval, @status.to_s]
      end
    end # class Recurrence

    class Occurence
      attr_reader :exec_time

      def initialize(recurrence, standard_time)
        if recurrence.status == false
          raise RuntimeError
        end

        exec_time = calc_next_time(recurrence.start_time, standard_time, recurrence.interval)
        if exec_time == nil
          raise RuntimeError
        end

        @command = recurrence.command
        @channel = recurrence.channel
        @exec_time = exec_time
      end

      def should_execute?(deadline)
        if @exec_time <= deadline
          return true
        else
          return false
        end
      end

      def execute(client)
        puts "at command executing [#{@command}]..."
        client.say(channel: @channel, text: "at コマンドによるコマンド実行です．")
        text = 'swimmy ' + @command
        SlackRubyBot::Hooks::Message.new.call(
          client,
          Hashie::Mash.new(type: 'message', text: text, channel: @channel)
        )
      end

      private
      def calc_next_time(start_time, standard_time,interval)

        if standard_time <= start_time
          return start_time
        end

        st = start_time.to_date
        sd = standard_time.to_date
        date_enumerator = nil
        case interval
        when Interval::ONCE then
          date_enumerator = nil
        when Interval::DAY then
          date_enumerator = Enumdate.daily(st).forward_to(sd)
        when Interval::WDAY then
          date_enumerator =
            (Enumdate::EnumMerger.new() \
              << Enumdate.weekly(st, wday: 1).forward_to(sd) \
              << Enumdate.weekly(st, wday: 2).forward_to(sd) \
              << Enumdate.weekly(st, wday: 3).forward_to(sd) \
              << Enumdate.weekly(st, wday: 4).forward_to(sd) \
              << Enumdate.weekly(st, wday: 5).forward_to(sd) \
            )
        when Interval::WEEK then
          date_enumerator = Enumdate.weekly(st).forward_to(sd)
        when Interval::MONTH then
          date_enumerator = Enumdate.monthly_by_day(st).forward_to(sd)
        when Interval::YEAR then
          date_enumerator = Enumdate.yearly_by_day(st).forward_to(sd)
        else
          date_enumerator = nil
        end

        if date_enumerator == nil then
          return nil
        end

        next_time ||=
          date_enumerator.each do |date|
            time = Time.parse("#{date.to_s} #{start_time.strftime("%T %z")}")
            if time > standard_time then
              break time
            end
          end

        return next_time
      end
    end # class Occurence

    module Interval
      ONCE  = "Once"
      DAY   = "Every Day"
      WDAY  = "Every WeekDay"
      WEEK  = "Every Week"
      MONTH = "Every Month"
      YEAR  = "Every Year"

      def from_string(s)
        case s
        when nil, "Once" then ONCE
        when "day", "Every Day" then DAY
        when "weekday", "Every WeekDay" then WDAY
        when "week", "Every Week" then WEEK
        when "month", "Every Month" then MONTH
        when "year", "Every Year" then YEAR
        else ONCE
        end
      end
      module_function :from_string

      def valid?(s)
        if (s != ONCE) && (s != DAY) && (s != WDAY) && (s != WEEK) && (s != MONTH) && (s != YEAR)
          false
        else
          true
        end
      end
      module_function :valid?

    end # module Interval
  end # module Resource
end # module Swimmy
