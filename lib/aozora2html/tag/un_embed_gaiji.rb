# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 非埋め込み外字
    class UnEmbedGaiji < Aozora2Html::Tag::Gaiji
      def initialize(parser, desc)
        @desc = desc
        @escaped = false
        super
      end

      def to_s
        '<span class="notes">［'.encode('shift_jis') + @desc + '］</span>'.encode('shift_jis')
      end

      def escaped?
        @escaped
      end

      def escape!
        @escaped = true
      end
    end
  end
end
