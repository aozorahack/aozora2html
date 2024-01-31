# frozen_string_literal: true

require_relative '../string_refinements'

class Aozora2Html
  class Tag
    # 非埋め込み外字
    class UnEmbedGaiji < Aozora2Html::Tag::Gaiji
      def initialize(parser, desc)
        @desc = desc
        @escaped = false
        super
      end

      using StringRefinements

      def to_s
        '<span class="notes">' + COMMAND_BEGIN + @desc + COMMAND_END + '</span>' # rubocop:disable Style/StringConcatenation
      end

      def escaped?
        @escaped
      end

      def escape!
        @escaped = true
      end
    end
  end
end
