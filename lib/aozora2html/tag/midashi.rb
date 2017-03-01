class Aozora2Html
  class Tag
    class Midashi < Aozora2Html::Tag::ReferenceMentioned

      def initialize(parser, target, size, type)
        super
        @target = target
        @tag = if size.match(SIZE_SMALL)
                 @id = parser.new_midashi_id(1)
                 "h5"
               elsif size.match(SIZE_MIDDLE)
                 @id = parser.new_midashi_id(10)
                 "h4"
               elsif size.match(SIZE_LARGE)
                 @id = parser.new_midashi_id(100)
                 "h3"
               else
                 raise Aozora2Html::Error.new(I18n.t(:undefined_header))
               end
        @class = case type
                 when :normal
                   case @tag
                   when "h5"
                     "ko-midashi"
                   when "h4"
                     "naka-midashi"
                   when "h3"
                     "o-midashi"
                   end
                 when :dogyo
                   case @tag
                   when "h5"
                     "dogyo-ko-midashi"
                   when "h4"
                     "dogyo-naka-midashi"
                   when "h3"
                     "dogyo-o-midashi"
                   end
                 when :mado
                   case @tag
                   when "h5"
                     "mado-ko-midashi"
                   when "h4"
                     "mado-naka-midashi"
                   when "h3"
                     "mado-o-midashi"
                   end
                 else
                   raise Aozora2Html::Error.new(I18n.t(:undefined_header))
                 end
      end

      def to_s
        "<#{@tag} class=\"#{@class}\"><a class=\"midashi_anchor\" id=\"midashi#{@id}\">#{@target}</a></#{@tag}>"
      end
    end
  end
end
