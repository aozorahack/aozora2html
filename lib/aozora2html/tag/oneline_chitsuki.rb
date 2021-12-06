# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 1行地付き用
    class OnelineChitsuki < Aozora2Html::Tag::Chitsuki
      include Aozora2Html::Tag::OnelineIndent
    end
  end
end
