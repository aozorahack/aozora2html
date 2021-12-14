# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 編集者による訂正用
    class EditorNote < Aozora2Html::Tag::Inline
      def initialize(parser, desc)
        @desc = desc
        super
      end

      def to_s
        '<span class="notes">［＃'.encode('shift_jis') + @desc + '］</span>'.encode('shift_jis')
      end
    end
  end
end
