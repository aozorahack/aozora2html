require "aozora2html/tag/inline"
require "aozora2html/tag/block"
require "aozora2html/tag/accent"
require "aozora2html/tag/gaiji"
require "aozora2html/tag/embed_gaiji"
require "aozora2html/tag/un_embed_gaiji"
require "aozora2html/tag/editor_note"
require "aozora2html/tag/indent"
require "aozora2html/tag/oneline_indent"
require "aozora2html/tag/multiline"
require "aozora2html/tag/multiline_style"
require "aozora2html/tag/font_size"
require "aozora2html/tag/jizume"
require "aozora2html/tag/keigakomi"
require "aozora2html/tag/multiline_yokogumi"
require "aozora2html/tag/multiline_caption"
require "aozora2html/tag/multiline_midashi"
require "aozora2html/tag/jisage"
require "aozora2html/tag/oneline_jisage"
require "aozora2html/tag/multiline_jisage"
require "aozora2html/tag/chitsuki"
require "aozora2html/tag/oneline_chitsuki"
require "aozora2html/tag/multiline_chitsuki"
require "aozora2html/tag/reference_mentioned"
require "aozora2html/tag/midashi"
require "aozora2html/tag/ruby"
require "aozora2html/tag/kunten"
require "aozora2html/tag/kaeriten"
require "aozora2html/tag/okurigana"
require "aozora2html/tag/inline_keigakomi"
require "aozora2html/tag/inline_yokogumi"
require "aozora2html/tag/inline_caption"
require "aozora2html/tag/inline_font_size"
require "aozora2html/tag/decorate"
require "aozora2html/tag/dakuten_katakana"
require "aozora2html/tag/dir"
require "aozora2html/tag/img"

# 変換される青空記法class
class Aozora2Html
  class Tag
    # debug用
    def inspect
      to_s
    end

    def syntax_error
      raise Aozora2Html::Error.new(I18n.t(:tag_syntax_error))
    end
  end
end
