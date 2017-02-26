class Aozora2Html
  class Tag
    class Img < Aozora2Html::Tag
      include Aozora2Html::Tag::Inline

      def initialize(parser, filename, css_class, alt, width, height)
        @filename = filename; @css_class = css_class; @alt = alt; @width = width; @height = height
        super
      end

      def to_s
        "<img class=\"#{@css_class}\" width=\"#{@width}\" height=\"#{@height}\" src=\"#{@filename}\" alt=\"#{@alt}\" />"
      end
    end
  end
end

