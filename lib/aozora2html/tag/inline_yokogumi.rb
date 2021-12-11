# frozen_string_literal: true

class Aozora2Html
  class Tag
    # インライン横組み用
    class InlineYokogumi < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span class=\"yokogumi\">#{@target}</span>"
      end
    end
  end
end
