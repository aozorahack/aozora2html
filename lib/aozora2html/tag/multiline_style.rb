# frozen_string_literal: true

class Aozora2Html
  class Tag
    class MultilineStyle < Aozora2Html::Tag
      include Aozora2Html::Tag::Multiline
      include Aozora2Html::Tag::Block

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
