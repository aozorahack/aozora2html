# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 返り点用
    class Kaeriten < Aozora2Html::Tag::Kunten
      def initialize(parser, string)
        @string = string
        super
      end

      def to_s
        "<sub class=\"kaeriten\">#{@string}</sub>"
      end
    end
  end
end
