# frozen_string_literal: true

class Aozora2Html
  class Tag
    # ブロックタグ用class
    #
    # 各Tagクラスはこれを継承する
    class Block < Aozora2Html::Tag
      def initialize(parser, *_args)
        super()

        syntax_error unless parser.block_allowed_context?
      end

      # 必要に基づきmethod overrideする
      def close_tag
        '</div>'
      end
    end
  end
end
