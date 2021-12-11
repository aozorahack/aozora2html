# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 複数行キャプション用
    class MultilineCaption < Aozora2Html::Tag
      include Aozora2Html::Tag::Multiline
      include Aozora2Html::Tag::Block

      def to_s
        '<div class="caption">'
      end
    end
  end
end
