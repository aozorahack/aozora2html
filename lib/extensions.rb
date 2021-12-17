# frozen_string_literal: true

# String extension
class String
  # used in Aozora2Html#char_type
  def char_type
    ch = self
    if ch.match(Aozora2Html::REGEX_HIRAGANA)
      :hiragana
    elsif ch.match(Aozora2Html::REGEX_KATAKANA)
      :katakana
    elsif ch.match(Aozora2Html::REGEX_ZENKAKU)
      :zenkaku
    elsif ch.match(Aozora2Html::REGEX_HANKAKU)
      :hankaku
    elsif ch.match(Aozora2Html::REGEX_KANJI)
      :kanji
    elsif ch.match?(/[.;"?!)]/)
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
