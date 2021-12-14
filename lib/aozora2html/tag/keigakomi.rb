# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 罫囲み用
    class Keigakomi < Aozora2Html::Tag::Block
      include Aozora2Html::Tag::Multiline

      def initialize(parser, size = 1)
        @size = size
        super
      end

      def to_s
        "<div class=\"keigakomi\" style=\"border: solid #{@size}px\">"
      end
    end
  end
end
