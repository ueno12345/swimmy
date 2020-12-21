module Swimmy
  module Resource
    class Calendar
      attr_reader :name, :id

      def initialize(name, id)
        @name, @id = name, id
      end

      def to_a
        [
          @name,
          @id
        ]
      end

    end # class Memo
  end # module Resource
end # module Swimmy
