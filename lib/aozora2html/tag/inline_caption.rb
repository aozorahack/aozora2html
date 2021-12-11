# frozen_string_literal: true

class Aozora2Html
  class Tag
    # インラインキャプション
    class InlineCaption < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span class=\"caption\">#{@target}</span>"
      end
    end
  end
end
