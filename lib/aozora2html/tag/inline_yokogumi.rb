class Aozora2Html
  class Tag
    class InlineYokogumi < Aozora2Html::Tag::ReferenceMentioned

      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span class=\"yokogumi\">#{@target.to_s}</span>"
      end
    end
  end
end

