# frozen_string_literal: true

class Aozora2Html
  # Internationalization(I18n) class
  #
  # コード内に日本語メッセージが氾濫しないようにするためのクラス
  class I18n
    MSG = {
      tag_syntax_error: '注記を重ねる際の原則、「狭い範囲を先に、広い範囲を後に」が守られていません。リンク先の指針を参考に、書き方をあらためてください',
      undefined_header: '未定義な見出しです',
      use_crlf: '改行コードを、「CR+LF」にあらためてください',
      error_stop: "エラー(%d行目):%s. \r\n処理を停止します",
      invalid_font_size: '文字サイズの指定が不正です',
      unsupported_ruby: 'サポートされていない複雑なルビ付けです',
      warn_onebyte: '警告(%d行目):1バイトの「%s」が使われています',
      warn_chuki: '警告(%d行目):注記記号の誤用の可能性がある、「%s」が使われています',
      warn_jis_gaiji: '警告(%d行目):JIS外字「%s」が使われています',
      dont_crlf_in_style: '%s中に改行されました。改行をまたぐ要素にはブロック表記を用いてください',
      terminate_in_style: '%s中に本文が終了しました',
      invalid_closing: '%sを閉じようとしましたが、%s中ではありません',
      invalid_nesting: '%sを終了しようとしましたが、%s中です',
      dont_use_double_ruby: '同じ箇所に2つのルビはつけられません',
      dont_allow_triple_ruby: '1つの単語に3つのルビはつけられません',
      warn_unexpected_terminator: '警告(%d行目):予期せぬファイル終端',
      warn_undefined_command: '警告(%d行目):「%s」は未対応のコマンドのため無視します'
    }.freeze

    def self.t(msg, *args)
      (MSG[msg].encode('shift_jis') % args)
    end
  end
end
