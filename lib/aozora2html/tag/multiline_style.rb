class Aozora2Html
  class Tag
    class MultilineStyle < Aozora2Html::Tag
      include Aozora2Html::Tag::Block, Aozora2Html::Tag::Multiline

      def initialize (parser, style)
        @style = style
        super
      end

      def to_s
        "<div class=\"#{@style}\">"
      end
    end
  end
end

