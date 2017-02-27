# 青空記法の入れ子に対応（？）
class Aozora2Html
  class TagParser < Aozora2Html
    def initialize (input, endchar, chuuki, image)
      if not(input.is_a?(Jstream))
        raise ArgumentError, "tag_parser must supply Jstream as input"
      end
      @stream = input;
      @buffer = []
      @ruby_buf = [""]
      @ruby_char_type = nil
      @chuuki_table = chuuki
      @images = image; # globalな環境を記録するアイテムは共有する必要あり
      @endchar = endchar # 改行を越えるべきか否か…
      @section = :tail # 末尾処理と記法内はインデントをしないので等価
      @raw = "" # 外字変換前の生テキストを残したいことがあるらしい
      @ruby_buf_protected = nil
      @ruby_buf_type = nil
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
      ruby_buf_dump
      ans=""
      @buffer.each{|s|
        if s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) and not(s.escaped?)
          # 消してあった※を復活させて
          ans.concat("※".encode("shift_jis"))
        end
        ans.concat(s.to_s)
      }
      [ans,@raw]
    end

    def process ()
      catch(:terminate){
        loop{
          parse
        }
      }
      general_output
    end
  end
end
