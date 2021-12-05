class Aozora2Html
  class Tag
    class FontSize < Aozora2Html::Tag
      include Aozora2Html::Tag::Multiline
      include Aozora2Html::Tag::Block

      def initialize(parser, times, daisho)
        @class = daisho.to_s + times.to_s
        @style = Utils.create_font_size(times, daisho)
        super
      end

      def to_s
        "<div class=\"#{@class}\" style=\"font-size: #{@style};\">"
      end
    end
  end
end
