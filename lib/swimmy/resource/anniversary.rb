module Swimmy
    module Resource
      class Anniversary
        attr_reader :month, :day, :title
  
        def initialize(month, day, title)
          @month, @day, @title = month, day, title
        end

        def occur_on?(date_or_time)
          date_or_time.strftime('%-m') == @month && date_or_time.strftime('%-d') == @day
        end

        def ==(obj)
          @month == obj.month && @day == obj.day && obj.title
        end
  
      end # class Anniversary
    end # module Resource
  end # module Swimmy
