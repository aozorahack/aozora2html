# frozen_string_literal: true

require_relative 'string_refinements'

class Aozora2Html
  # ルビ文字列解析用バッファ
  class RubyBuffer
    # `｜`が来た時に真にする。ルビの親文字のガード用。
    attr_accessor :protected

    def initialize
      clear
    end

    # バッファの初期化。`""`の1要素のバッファにする。
    def clear
      @ruby_buf = [+'']
      @protected = nil
      @char_type = nil
    end

    def empty?
      @ruby_buf.empty?
    end

    def present?
      !empty?
    end

    def to_a
      @ruby_buf
    end

    def create_ruby(parser, ruby)
      ans = +''
      notes = []

      @ruby_buf.each do |token|
        if token.is_a?(Aozora2Html::Tag::UnEmbedGaiji)
          ans.concat(GAIJI_MARK)
          token.escape!
          notes.push(token)
        else
          ans.concat(token.to_s)
        end
      end

      notes.unshift(Aozora2Html::Tag::Ruby.new(parser, ans, ruby))
      clear

      notes
    end

    def last
      @ruby_buf.last
    end

    # バッファ末尾にitemを追加する
    #
    # itemとバッファの最後尾がどちらもStringであれば連結したStringにし、
    # そうでなければバッファの末尾に新しい要素として追加する
    def push(item)
      if last.is_a?(String) && item.is_a?(String)
        @ruby_buf.last.concat(item)
      else
        @ruby_buf.push(item)
      end
    end

    def length
      @ruby_buf.length
    end

    # buffer management
    def dump_into(buffer)
      if @protected
        @ruby_buf.unshift(RUBY_PREFIX)
        @protected = nil
      end
      top = @ruby_buf[0]
      if top.is_a?(String) && buffer.last.is_a?(String)
        buffer.last.concat(top)
        buffer.concat(@ruby_buf[1, @ruby_buf.length])
      else
        buffer.concat(@ruby_buf)
      end
      clear
      buffer
    end

    def push_char(char, buffer)
      ctype = char_type(char)
      if (ctype == :hankaku_terminate) && (@char_type == :hankaku)
        push(char)
        @char_type = :else
      elsif @protected || ((ctype != :else) && (ctype == @char_type))
        push(char)
      else
        dump_into(buffer)
        push(char)
        @char_type = ctype
      end
    end

    private

    using StringRefinements

    def char_type(char)
      ## `String#char_type`も定義されているのに注意
      char.char_type
    rescue StandardError
      :else
    end
  end
end
