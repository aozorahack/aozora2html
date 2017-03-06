class Aozora2Html
  class Tag
    class Decorate < Aozora2Html::Tag::ReferenceMentioned

      def initialize(parser, target, html_class, html_tag)
        @target = target
        @close = "</#{html_tag}>"
        @open = "<#{html_tag} class=\"#{html_class}\">"
        super
      end

      def to_s
        @open+@target.to_s+@close
      end
    end
  end
end

