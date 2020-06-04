module Swimmy
  module Resource
    class Attendance
      attr_reader :time, :inout, :member_name

      def initialize(time, inout, member_name, comment)
        @time, @inout, @member_name, @comment = time, inout, member_name, comment
      end

      def to_a
        [
          time.strftime('%Y-%m-%d %H:%M:%S'),
          @inout,
          @member_name,
          @comment
        ]
      end

      def to_s
        "Time: #{time.strftime('%Y-%m-%d %H:%M:%S')}\n" +
          "InOut: #{inout}\n" +
          "MemberName: #{member_name}\n" +
          "Comment: #{comment}\n"
      end
    end # class Attendance
  end # module Resource
end # module Swimmy
