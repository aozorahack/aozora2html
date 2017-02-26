# encoding: utf-8
class Aozora2Html

  # accent特殊文字を生かすための再帰呼び出し
  class AccentParser < Aozora2Html

    def initialize (input, endchar, chuuki, image)
      if not(input.is_a?(Jstream))
        raise ArgumentError, "tag_parser must supply Jstream as input"
      end
      @stream = input
      @buffer = []
      @ruby_buf = [""]
      @ruby_char_type = nil
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行は越えられない <br />を出力していられない
      @closed = nil # 改行での強制撤退チェックフラグ
      @encount_accent = nil
    end

    def general_output # 出力は配列で返す
      ruby_buf_dump
      if not(@encount_accent)
        @buffer.unshift("〔".encode("shift_jis"))
      end
      if @closed and not(@encount_accent)
        @buffer.push("〕".encode("shift_jis"))
      elsif not(@closed)
        @buffer.push("<br />\r\n")
      end
      @buffer
    end

    def parse
      first = read_char
      if found = @@accent_table[first]
        if found2 = found[@stream.peek_char(0)]
          if found2.is_a?(Hash)
            if found3 = found2[@stream.peek_char(1)]
              first = Aozora2Html::Tag::Accent.new(self, *found3)
              @encount_accent = true
              @chuuki_table[:accent] = true
              read_char
              read_char
            end
          elsif found2
            first = Aozora2Html::Tag::Accent.new(self, *found2)
            @encount_accent = true
            read_char
            @chuuki_table[:accent] = true
          end
        end
      end
      case first
      when "※".encode("shift_jis")
        first = dispatch_gaiji
      when "［".encode("shift_jis")
        first = dispatch_aozora_command
      when @@ku
        assign_kunoji
      when "《".encode("shift_jis")
        first = apply_ruby
      end
      if first == "\r\n"
        if @encount_accent
          puts "警告(#{scount}行目):アクセント分解の亀甲括弧の始めと終わりが、行中で揃っていません".encode("shift_jis")
        end
        throw :terminate
      elsif first == "〕".encode("shift_jis")
        @closed = true
        throw :terminate
      elsif first == "｜".encode("shift_jis")
        ruby_buf_dump
        @ruby_buf_protected = true
      elsif first != "" and first != nil
        illegal_char_check(first)
        push_chars(first)
      end
    end

    def process
      catch(:terminate) do
        loop do
          parse
        end
      end
      general_output
    end
  end
end
