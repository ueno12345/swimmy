module Swimmy
  module Resource
    class Memo
      attr_reader :time, :member_name, :comment

      def initialize(time, member_name, comment)
        @time, @member_name, @comment = time, member_name, comment
      end

      def to_a
        [
          time.strftime('%Y-%m-%d %H:%M:%S'),
          @member_name,
          @comment
        ]
      end

      def to_s
        "Time: #{time.strftime('%Y-%m-%d %H:%M:%S')}\n" +
          "MemberName: #{member_name}\n" +
          "Comment: #{comment}\n"
      end
    end # class Memo
  end # module Resource
end # module Swimmy
