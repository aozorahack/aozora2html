# frozen_string_literal: true

require_relative 'ruby_buffer'

class Aozora2Html
  # accent特殊文字を生かすための再帰呼び出し
  class AccentParser < Aozora2Html
    def initialize(input, endchar, chuuki, image, gaiji_dir:, use_jisx0213: nil) # rubocop:disable Lint/MissingSuper
      unless input.is_a?(Jstream)
        raise ArgumentError, 'tag_parser must supply Jstream as input'
      end

      @stream = input
      @gaiji_dir = gaiji_dir
      @buffer = Aozora2Html::TextBuffer.new
      @ruby_buf = Aozora2Html::RubyBuffer.new
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行は越えられない <br />を出力していられない
      @closed = nil # 改行での強制撤退チェックフラグ
      @encount_accent = nil
      @use_jisx0213 = use_jisx0213
    end

    # 出力は配列で返す
    def general_output
      @ruby_buf.dump_into(@buffer)
      unless @encount_accent
        @buffer.unshift(ACCENT_BEGIN)
      end
      if @closed && !@encount_accent
        @buffer.push(ACCENT_END)
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
              code, name = found2[@stream.peek_char(1)]
              if code
                first = Aozora2Html::Tag::Accent.new(self, code, name, gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213)
                @encount_accent = true
                @chuuki_table[:accent] = true
                read_char
                read_char
              end
            elsif found2.is_a?(Array)
              code, name = found2[0], found2[1]
              first = Aozora2Html::Tag::Accent.new(self, code, name, gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213)
              @encount_accent = true
              read_char
              @chuuki_table[:accent] = true
            end
          end
        end

        case first
        when Aozora2Html::GAIJI_MARK
          first = dispatch_gaiji
        when COMMAND_BEGIN
          first = dispatch_aozora_command
        when Aozora2Html::KU
          assign_kunoji
        when RUBY_BEGIN_MARK
          first = apply_ruby
        end
        if first == "\r\n"
          if @encount_accent
            puts I18n.t(:warn_invalid_accent_brancket, line_number)
          end
          throw :terminate
        elsif first == ACCENT_END
          @closed = true
          throw :terminate
        elsif first == RUBY_PREFIX
          @ruby_buf.dump_into(@buffer)
          @ruby_buf.protected = true
        elsif (first != '') && !first.nil?
          Utils.illegal_char_check(first, line_number)
          push_chars(escape_special_chars(first))
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
