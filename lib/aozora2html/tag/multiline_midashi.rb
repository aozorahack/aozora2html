class Aozora2Html
  class Tag
    class MultilineMidashi < Aozora2Html::Tag
      include Aozora2Html::Tag::Block, Aozora2Html::Tag::Multiline

      def initialize(parser,size,type)
        super
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
        @class = Utils.create_midashi_class(type, @tag)
      end

      def to_s
        "<#{@tag} class=\"#{@class}\"><a class=\"midashi_anchor\" id=\"midashi#{@id}\">"
      end

      def close_tag
        "</a></#{@tag}>"
      end
    end
  end
end
