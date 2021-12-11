# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックでの字下げ指定用
    class MultilineJisage < Aozora2Html::Tag::Jisage
      include Aozora2Html::Tag::Multiline
    end
  end
end
