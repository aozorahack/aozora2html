# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 1行字下げ用
    class OnelineJisage < Aozora2Html::Tag::Jisage
      include Aozora2Html::Tag::OnelineIndent
    end
  end
end
