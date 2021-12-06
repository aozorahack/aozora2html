# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 字詰め用
    class Jizume < Aozora2Html::Tag::Indent
      include Aozora2Html::Tag::Multiline

      def initialize(parser, width)
        @w = width
        super
      end

      def to_s
        "<div class=\"jizume_#{@w}\" style=\"width: #{@w}em\">"
      end
    end
  end
end
