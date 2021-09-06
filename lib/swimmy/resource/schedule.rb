require 'time'

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
        match_data = s.match(/(every (day|week|month|year) )*(.+) do (.+)/)

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

      def initialize(recurrence)
        if recurrence.status == false
          raise RuntimeError
        end

        exec_time = calc_next_time(recurrence.start_time, recurrence.interval)
        if exec_time == nil
          raise RuntimeError
        end

        @command = recurrence.command
        @channel = recurrence.channel
        @exec_time = exec_time
      end

      def should_execute?
        if @exec_time <= Time.now
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
      def calc_next_time(start_time, interval)

        now_time = Time.now
        if now_time < start_time
          return start_time
        end

        case interval
        when Interval::ONCE then
          return nil
        when Interval::DAY then
          method = "next_day"
        when Interval::WEEK then
          method = "next_week"
        when Interval::MONTH then
          method = "next_month"
        when Interval::YEAR then
          method = "next_year"
        else return nil
        end

        time = start_time
        while time < now_time do
          date = time.to_date
          eval("next_date = date.#{method}")
          time_str = "#{next_date.to_s} #{start_time.strftime("%H:%M:%S")}"
          time = Time.parse(time_str)
        end

        return time
      end
    end # class Occurence

    module Interval
      ONCE  = "Once"
      DAY   = "Every Day"
      WEEK  = "Every Week"
      MONTH = "Every Month"
      YEAR  = "Every Year"

      def from_string(s)
        case s
        when nil, "Once" then ONCE
        when "day", "Every Day" then DAY
        when "week", "Every Week" then WEEK
        when "month", "Every Month" then MONTH
        when "year", "Every Year" then YEAR
        else ONCE
        end
      end
      module_function :from_string

      def valid?(s)
        if (s != ONCE) && (s != DAY) && (s != WEEK) && (s != MONTH) && (s != YEAR)
          false
        else
          true
        end
      end
      module_function :valid?

    end # module Interval
  end # module Resource
end # module Swimmy
