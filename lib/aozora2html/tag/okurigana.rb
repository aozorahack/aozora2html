class Aozora2Html
  class Tag
    class Okurigana < Aozora2Html::Tag::Kunten
      def initialize(parser, string)
        @string = string
        super
      end

      def to_s
        "<sup class=\"okurigana\">#{@string.to_s}</sup>"
      end
    end
  end
end
