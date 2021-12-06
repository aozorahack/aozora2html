# frozen_string_literal: true

class Aozora2Html
  class Tag
    class Keigakomi < Aozora2Html::Tag
      include Aozora2Html::Tag::Multiline
      include Aozora2Html::Tag::Block

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
