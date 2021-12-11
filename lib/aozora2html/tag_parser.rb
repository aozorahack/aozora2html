# frozen_string_literal: true

require_relative 'ruby_buffer'

class Aozora2Html
  # 注記記法parser
  #
  # 青空記法の入れ子に対応（？）
  class TagParser < Aozora2Html
    def initialize(input, endchar, chuuki, image, gaiji_dir:) # rubocop:disable Lint/MissingSuper
      unless input.is_a?(Jstream)
        raise ArgumentError, 'tag_parser must supply Jstream as input'
      end

      @stream = input
      @gaiji_dir = gaiji_dir
      @buffer = []
      @ruby_buf = RubyBuffer.new
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行を越えるべきか否か…
      @section = :tail # 末尾処理と記法内はインデントをしないので等価
      @raw = +'' # 外字変換前の生テキストを残したいことがあるらしい
    end

    # method override!
    def read_char
      c = @stream.read_char
      @raw.concat(c)
      c
    end

    def read_to_nest(endchar)
      ans = super(endchar)
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
