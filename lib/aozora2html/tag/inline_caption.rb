class Aozora2Html
  class Tag
    class InlineCaption < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span class=\"caption\">#{@target.to_s}</span>"
      end
    end
  end
end
