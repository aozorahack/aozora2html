# frozen_string_literal: true

class Aozora2Html
  class Tag
    # インライン罫囲み用
    class InlineKeigakomi < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span class=\"keigakomi\">#{@target}</span>"
      end
    end
  end
end
