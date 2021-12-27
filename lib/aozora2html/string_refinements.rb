# frozen_string_literal: true

class Aozora2Html
  # String extension
  module StringRefinements
    refine String do
      # used in RubyBuffer#char_type
      def char_type
        case self
        when Aozora2Html::REGEX_HIRAGANA
          :hiragana
        when Aozora2Html::REGEX_KATAKANA
          :katakana
        when Aozora2Html::REGEX_ZENKAKU
          :zenkaku
        when Aozora2Html::REGEX_HANKAKU
          :hankaku
        when Aozora2Html::REGEX_KANJI
          :kanji
        when /[.;"?!)]/
          :hankaku_terminate
        else
          :else
        end
      end

      def to_sjis
        encode('shift_jis')
      end
    end
  end
end
