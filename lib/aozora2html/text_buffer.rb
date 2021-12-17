# frozen_string_literal: true

class Aozora2Html
  # 本文テキスト用バッファ
  #
  # 要素はString以外も含む
  class TextBuffer < Array
    # 行出力時に@bufferが空かどうか調べる
    #
    # @bufferの中身によって行末の出力が異なるため
    #
    # @return [true, false, :inline] 空文字ではない文字列が入っていればfalse、1行注記なら:inline、それ以外しか入っていなければtrue
    #
    def is_blank?
      each do |token|
        return false if token.is_a?(String) && token != ''

        if token.is_a?(Aozora2Html::Tag::OnelineIndent)
          return :inline
        end
      end
      true
    end

    # 行末で<br />を出力するべきかどうかの判別用
    #
    # @return [true, false] Multilineの注記しか入っていなければfalse、Multilineでも空文字でもない要素が含まれていればtrue
    #
    def terpri?
      flag = true
      each do |x|
        case x
        when Aozora2Html::Tag::Multiline
          flag = false
        when ''
        # skip
        else
          return true
        end
      end

      flag
    end

    def to_s
      join
    end
  end
end
