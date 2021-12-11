# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックタグ用module
    #
    # 各Tagクラスにてincludeして使う
    module Block
      def initialize(parser, *_args)
        if parser.block_allowed_context?
          nil
        else
          syntax_error
        end
      end

      # 必要に基づきmethod overrideする
      def close_tag
        '</div>'
      end
    end
  end
end
