# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックでの見出し指定用
    class MultilineMidashi < Aozora2Html::Tag::Block
      include Aozora2Html::Tag::Multiline

      def initialize(parser, size, type)
        super
        @tag = Utils.create_midashi_tag(size)
        @id = parser.new_midashi_id(size)
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
