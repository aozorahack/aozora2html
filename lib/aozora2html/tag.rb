# frozen_string_literal: true

require_relative 'tag/inline'
require_relative 'tag/block'
require_relative 'tag/accent'
require_relative 'tag/gaiji'
require_relative 'tag/embed_gaiji'
require_relative 'tag/un_embed_gaiji'
require_relative 'tag/editor_note'
require_relative 'tag/indent'
require_relative 'tag/oneline_indent'
require_relative 'tag/multiline'
require_relative 'tag/multiline_style'
require_relative 'tag/font_size'
require_relative 'tag/jizume'
require_relative 'tag/keigakomi'
require_relative 'tag/multiline_yokogumi'
require_relative 'tag/multiline_caption'
require_relative 'tag/multiline_midashi'
require_relative 'tag/jisage'
require_relative 'tag/oneline_jisage'
require_relative 'tag/multiline_jisage'
require_relative 'tag/chitsuki'
require_relative 'tag/oneline_chitsuki'
require_relative 'tag/multiline_chitsuki'
require_relative 'tag/reference_mentioned'
require_relative 'tag/midashi'
require_relative 'tag/ruby'
require_relative 'tag/kunten'
require_relative 'tag/kaeriten'
require_relative 'tag/okurigana'
require_relative 'tag/inline_keigakomi'
require_relative 'tag/inline_yokogumi'
require_relative 'tag/inline_caption'
require_relative 'tag/inline_font_size'
require_relative 'tag/decorate'
require_relative 'tag/dir'
require_relative 'tag/img'

class Aozora2Html
  # 変換される青空記法class
  class Tag
    # debug用
    def inspect
      to_s
    end

    def char_type
      :else
    end

    def syntax_error
      raise Aozora2Html::Error, I18n.t(:tag_syntax_error)
    end
  end
end
