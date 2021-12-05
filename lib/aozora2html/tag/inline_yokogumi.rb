class Aozora2Html
  class Tag
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
