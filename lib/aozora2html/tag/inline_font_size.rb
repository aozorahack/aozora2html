class Aozora2Html
  class Tag
    class InlineFontSize < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target, times, daisho)
        @target = target
        @class = daisho.to_s + times.to_s
        @style = Utils.create_font_size(times, daisho)
        super
      end

      def to_s
        "<span class=\"#{@class}\" style=\"font-size: #{@style};\">#{@target}</span>"
      end
    end
  end
end
