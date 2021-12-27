# frozen_string_literal: true

# String extension
class String
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

# Kernel extension
module Kernel
  alias original_kernel_puts puts

  def puts(*args)
    original_kernel_puts(args)
  rescue Encoding::CompatibilityError
    original_kernel_puts(args.map { |arg| arg.force_encoding('utf-8') })
  end
end
