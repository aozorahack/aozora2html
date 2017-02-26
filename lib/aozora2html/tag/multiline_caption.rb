class Aozora2Html
  class Tag
    class MultilineCaption < Aozora2Html::Tag
      include Aozora2Html::Tag::Block, Aozora2Html::Tag::Multiline

      def initialize(parser)
        super
      end

      def to_s
        "<div class=\"caption\">"
      end
    end
  end
end
