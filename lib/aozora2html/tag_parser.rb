# 青空記法の入れ子に対応（？）
require 'aozora2html/ruby_buffer'
class Aozora2Html
  class TagParser < Aozora2Html
    def initialize(input, endchar, chuuki, image)
      if not(input.is_a?(Jstream))
        raise ArgumentError, "tag_parser must supply Jstream as input"
      end
      @stream = input
      @buffer = []
      @ruby_buf = RubyBuffer.new
      @chuuki_table = chuuki
      @images = image # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行を越えるべきか否か…
      @section = :tail # 末尾処理と記法内はインデントをしないので等価
      @raw = "" # 外字変換前の生テキストを残したいことがあるらしい
    end

    def read_char # method override!
      c = @stream.read_char
      @raw.concat(c)
      c
    end

    def read_to_nest(endchar)
      ans = super(endchar)
      @raw.concat(ans[1])
      ans
    end

    def general_output # 出力は[String,String]返しで！
      @ruby_buf.dump_into(@buffer)
      ans=""
      @buffer.each do |s|
        if s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) and !s.escaped?
          # 消してあった※を復活させて
          ans.concat(GAIJI_MARK)
        end
        ans.concat(s.to_s)
      end
      [ans,@raw]
    end

    def process()
      catch(:terminate) do
        loop do
          parse
        end
      end
      general_output
    end
  end
end
