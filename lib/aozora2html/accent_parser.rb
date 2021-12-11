# frozen_string_literal: true

require_relative 'ruby_buffer'

class Aozora2Html
  # accent特殊文字を生かすための再帰呼び出し
  class AccentParser < Aozora2Html
    def initialize(input, endchar, chuuki, image, gaiji_dir:) # rubocop:disable Lint/MissingSuper
      unless input.is_a?(Jstream)
        raise ArgumentError, 'tag_parser must supply Jstream as input'
      end

      @stream = input
      @gaiji_dir = gaiji_dir
      @buffer = []
      @ruby_buf = Aozora2Html::RubyBuffer.new
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行は越えられない <br />を出力していられない
      @closed = nil # 改行での強制撤退チェックフラグ
      @encount_accent = nil
    end

    # 出力は配列で返す
    def general_output
      @ruby_buf.dump_into(@buffer)
      unless @encount_accent
        @buffer.unshift('〔'.encode('shift_jis'))
      end
      if @closed && !@encount_accent
        @buffer.push('〕'.encode('shift_jis'))
      elsif !@closed
        @buffer.push("<br />\r\n")
      end
      @buffer
    end

    def parse
      loop do
        first = read_char

        found = Aozora2Html::ACCENT_TABLE[first]
        if found
          found2 = found[@stream.peek_char(0)]
          if found2
            if found2.is_a?(Hash)
              found3 = found2[@stream.peek_char(1)]
              if found3
                first = Aozora2Html::Tag::Accent.new(self, *found3, gaiji_dir: @gaiji_dir)
                @encount_accent = true
                @chuuki_table[:accent] = true
                read_char
                read_char
              end
            elsif found2
              first = Aozora2Html::Tag::Accent.new(self, *found2, gaiji_dir: @gaiji_dir)
              @encount_accent = true
              read_char
              @chuuki_table[:accent] = true
            end
          end
        end

        case first
        when Aozora2Html::GAIJI_MARK
          first = dispatch_gaiji
        when '［'.encode('shift_jis')
          first = dispatch_aozora_command
        when Aozora2Html::KU
          assign_kunoji
        when '《'.encode('shift_jis')
          first = apply_ruby
        end
        if first == "\r\n"
          if @encount_accent
            puts "警告(#{line_number}行目):アクセント分解の亀甲括弧の始めと終わりが、行中で揃っていません".encode('shift_jis')
          end
          throw :terminate
        elsif first == '〕'.encode('shift_jis')
          @closed = true
          throw :terminate
        elsif first == RUBY_PREFIX
          @ruby_buf.dump_into(@buffer)
          @ruby_buf.protected = true
        elsif (first != '') && !first.nil?
          Utils.illegal_char_check(first, line_number)
          push_chars(first)
        end
      end
    end

    def process
      catch(:terminate) do
        parse
      end
      general_output
    end
  end
end
