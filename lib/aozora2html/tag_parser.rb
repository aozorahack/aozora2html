# frozen_string_literal: true

require_relative 'ruby_buffer'

class Aozora2Html
  # 注記記法parser
  #
  # 青空記法の入れ子に対応（？）
  class TagParser < Aozora2Html
    def initialize(input, endchar, chuuki, image, gaiji_dir:, use_jisx0213: nil, use_unicode: nil) # rubocop:disable Lint/MissingSuper
      unless input.is_a?(Jstream)
        raise ArgumentError, 'tag_parser must supply Jstream as input'
      end

      @stream = input
      @gaiji_dir = gaiji_dir
      @use_jisx0213 = use_jisx0213
      @use_unicode = use_unicode
      @buffer = TextBuffer.new
      @ruby_buf = RubyBuffer.new
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      # 内部処理はUTF-8なので、endcharもUTF-8であること
      if endchar.is_a?(String) && endchar.encoding != Encoding::UTF_8
        raise ArgumentError, "endchar must be UTF-8 encoded, got #{endchar.encoding}"
      end

      @endchar = endchar
      @section = :tail # 末尾処理と記法内はインデントをしないので等価
      @raw = +'' # 外字変換前の生テキストを残したいことがあるらしい
      @out = OutputStream.new(StringIO.new) # ダミー出力（TagParser自体は出力を使わない）
    end

    # method override!
    def read_char
      c = @stream.read_char
      @raw.concat(c) if c.is_a?(String)
      c
    end

    def read_to_nest(endchar)
      ans = super
      @raw.concat(ans[1])
      ans
    end

    # 出力は[String,String]返しで！
    def general_output
      @ruby_buf.dump_into(@buffer)
      ans = +''
      @buffer.each do |s|
        if s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) && !s.escaped?
          # 消してあった※を復活させて
          ans.concat(GAIJI_MARK)
        end
        ans.concat(s.to_s)
      end
      [ans, @raw]
    end

    def process
      catch(:terminate) do
        parse
      end
      general_output
    end
  end
end
