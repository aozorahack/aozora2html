# frozen_string_literal: true

class Aozora2Html
  class Tag
    class Gaiji < Aozora2Html::Tag
      include Aozora2Html::Tag::Inline

      def char_type
        :kanji
      end
    end
  end
end
