# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックでの地付き指定用
    class MultilineChitsuki < Aozora2Html::Tag::Chitsuki
      include Aozora2Html::Tag::Multiline
    end
  end
end
