# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 濁点つきカタカナ用
    class DakutenKatakana < Aozora2Html::Tag::Inline
      def initialize(parser, num, katakana, gaiji_dir:)
        @n = num
        @katakana = katakana
        @gaiji_dir = gaiji_dir
        super
      end

      def char_type
        :katakana
      end

      def to_s
        "<img src=\"#{@gaiji_dir}/1-07/1-07-8#{@n}.png\" alt=\"" + '※(濁点付き片仮名「'.encode('shift_jis') + @katakana + '」、1-07-8'.encode('shift_jis') + "#{@n})\" class=\"gaiji\" />"
      end
    end
  end
end
