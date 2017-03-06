# encoding: utf-8
# 1.8 like to_s method to Array
class Array
  def to_s
    self.join
  end
end

class String

  # used in Aozora2Html#char_type
  def char_type
    ch = self
    if ch.match(Regexp.new("[ぁ-んゝゞ]".encode("shift_jis")))
      :hiragana
    elsif ch.match(Regexp.new("[ァ-ンーヽヾヴ]".encode("shift_jis")))
      :katakana
    elsif ch.match(Regexp.new("[０-９Ａ-Ｚａ-ｚΑ-Ωα-ωА-Яа-я−＆’，．]".encode("shift_jis")))
      :zenkaku
    elsif ch.match(Regexp.new("[A-Za-z0-9#\\-\\&'\\,]".encode("shift_jis")))
      :hankaku
    elsif ch.match(Regexp.new("[亜-熙々※仝〆〇ヶ]".encode("shift_jis")))
      :kanji
    elsif ch.match(/[\.\;\"\?\!\)]/)
      :hankaku_terminate
    else
      :else
    end
  end
end

