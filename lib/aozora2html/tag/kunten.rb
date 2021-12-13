# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 訓点用
    class Kunten < Aozora2Html::Tag::Inline
      def char_type
        :else # just remove this line
      end
    end
  end
end
