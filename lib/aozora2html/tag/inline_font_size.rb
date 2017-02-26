class Aozora2Html
  class Tag
    class InlineFontSize < Aozora2Html::Tag::ReferenceMentioned

      def initialize(parser, target, times, daisho)
        @target = target
        @class = daisho.to_s + times.to_s
        @style = case times
                 when 1
                   ""
                 when 2
                   "x-"
                 else
                   if times >= 3
                     "xx-"
                   else
                     raise Aozora2Html::Error.new(I18n.t(:invalid_font_size))
                   end
                 end + case daisho
                       when :dai
                         "large"
                       when :sho
                         "small"
                       end
        super
      end

      def to_s
        "<span class=\"#{@class}\" style=\"font-size: #{@style};\">" + @target.to_s + "</span>"
      end
    end
  end
end

