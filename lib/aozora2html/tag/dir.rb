class Aozora2Html
  class Tag
    class Dir < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span dir=\"ltr\">#{@target.to_s}</span>"
      end
    end
  end
end
