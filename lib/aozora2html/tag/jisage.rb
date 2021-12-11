# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 字下げ用
    class Jisage < Aozora2Html::Tag::Indent
      def initialize(parser, width)
        @width = width
        super
      end

      def to_s
        "<div class=\"jisage_#{@width}\" style=\"margin-left: #{@width}em\">"
      end
    end
  end
end
