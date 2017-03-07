# encoding: utf-8
class Aozora2Html
  class I18n
    MSG = {
      :tag_syntax_error => "注記を重ねる際の原則、「狭い範囲を先に、広い範囲を後に」が守られていません。リンク先の指針を参考に、書き方をあらためてください",
      :undefined_header => "未定義な見出しです",
      :use_crlf => "改行コードを、「CR+LF」にあらためてください",
      :error_stop => "エラー(%d行目):%s. \r\n処理を停止します",
      :invalid_font_size => "文字サイズの指定が不正です",
      :unsupported_ruby  => "サポートされていない複雑なルビ付けです"
    }

    def self.t(msg, *args)
      (MSG[msg].encode("shift_jis") % args)
    end
  end
end
