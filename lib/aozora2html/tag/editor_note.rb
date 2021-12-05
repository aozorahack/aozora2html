class Aozora2Html
  class Tag
    class EditorNote < Aozora2Html::Tag
      include Aozora2Html::Tag::Inline
      def initialize(parser, desc)
        @desc = desc
        super
      end

      def to_s
        '<span class="notes">［＃'.encode("shift_jis") + @desc + '］</span>'.encode("shift_jis")
      end
    end
  end
end
