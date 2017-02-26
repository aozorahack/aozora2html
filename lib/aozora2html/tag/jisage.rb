class Aozora2Html
  class Tag
    class Jisage < Aozora2html::Tag::Indent

      def initialize(parser, width)
        @width = width
        super
      end

      def to_s
        "<div class=\"jisage_#{@width}\" style=\"margin-left: #{@width}em\">"
      end
    end
  end
end
