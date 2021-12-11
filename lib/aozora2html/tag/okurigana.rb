# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 訓点送り仮名用
    class Okurigana < Aozora2Html::Tag::Kunten
      def initialize(parser, string)
        @string = string
        super
      end

      def to_s
        "<sup class=\"okurigana\">#{@string}</sup>"
      end
    end
  end
end
