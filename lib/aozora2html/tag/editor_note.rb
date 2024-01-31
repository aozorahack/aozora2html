# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 編集者による訂正用
    class EditorNote < Aozora2Html::Tag::Inline
      def initialize(parser, desc)
        @desc = desc
        super
      end

      using StringRefinements

      def to_s
        '<span class="notes">' + COMMAND_BEGIN + IGETA_MARK + @desc + COMMAND_END + '</span>' # rubocop:disable Style/StringConcatenation
      end
    end
  end
end
