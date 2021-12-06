# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 地付き記法
    #
    # 直接使わない。実際に使うのはサブクラス
    class Chitsuki < Aozora2Html::Tag::Indent
      def initialize(parser, length)
        @length = length
        super
      end

      def to_s
        "<div class=\"chitsuki_#{@length}\" style=\"text-align:right; margin-right: #{@length}em\">"
      end
    end
  end
end
