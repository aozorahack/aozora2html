# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックでの横組指定用
    class MultilineYokogumi < Aozora2Html::Tag::Block
      include Aozora2Html::Tag::Multiline

      def to_s
        '<div class="yokogumi">'
      end
    end
  end
end
