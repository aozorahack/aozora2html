# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックでのスタイル指定用
    class MultilineStyle < Aozora2Html::Tag::Block
      include Aozora2Html::Tag::Multiline

      def initialize(parser, style)
        @style = style
        super
      end

      def to_s
        "<div class=\"#{@style}\">"
      end
    end
  end
end
