# frozen_string_literal: true

class Aozora2Html
  class Tag
    class Midashi < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target, size, type)
        super
        @target = target
        @tag = Utils.create_midashi_tag(size)
        @id = parser.new_midashi_id(size)
        @class = Utils.create_midashi_class(type, @tag)
      end

      def to_s
        "<#{@tag} class=\"#{@class}\"><a class=\"midashi_anchor\" id=\"midashi#{@id}\">#{@target}</a></#{@tag}>"
      end
    end
  end
end
