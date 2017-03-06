class Aozora2Html
  class Tag
    module Block
      def initialize(parser, *args)
        if parser.block_allowed_context?
          nil
        else
          syntax_error
        end
      end

      # 必要に基づきmethod overrideする
      def close_tag
        "</div>"
      end
    end
  end
end

