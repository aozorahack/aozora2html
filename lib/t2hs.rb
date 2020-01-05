# -*- coding:shift_jis -*-
# 青空文庫形式のテキストファイルを html に整形する ruby スクリプト
require "cgi"
require "extensions"
require "aozora2html/error"
require "jstream"
require "aozora2html/tag"
require "aozora2html/tag_parser"
require "aozora2html/accent_parser"
require "aozora2html/style_stack"
require "aozora2html/header"
require "aozora2html/ruby_buffer"
require "aozora2html/yaml_loader"
require "aozora2html/zip"
require "aozora2html/utils"

$gaiji_dir = "../../../gaiji/"

$css_files = Array["../../aozora.css"]

# 変換器本体
class Aozora2Html

  # 全角バックスラッシュが出せないから直打ち
  KU = ["18e5"].pack("h*").force_encoding("shift_jis")
  NOJI = ["18f5"].pack("h*").force_encoding("shift_jis")
  DAKUTEN = ["18d8"].pack("h*").force_encoding("shift_jis")
  GAIJI_MARK = "※"
  IGETA_MARK = "＃"
  RUBY_BEGIN_MARK = "《"
  RUBY_END_MARK = "》"
  PAREN_BEGIN_MARK = "（"
  PAREN_END_MARK = "）"
  SIZE_SMALL = "小"
  SIZE_MIDDLE = "中"
  SIZE_LARGE = "大"
  TEIHON_MARK = "底本："
  COMMAND_BEGIN = "［"
  COMMAND_END = "］"
  ACCENT_BEGIN = "〔"
  ACCENT_END = "〕"
  AOZORABUNKO = "青空文庫"
  #PAT_EDITOR = /[校訂|編|編集|編集校訂|校訂編集]$/
  PAT_EDITOR = /(校訂|編|編集)$/
  PAT_HENYAKU = /編訳$/
  PAT_TRANSLATOR = /訳$/
  RUBY_PREFIX = "｜"
  PAT_RUBY = /《.*?》/
  PAT_DIRECTION = /(右|左|上|下)に(.*)/
  PAT_REF = /^「.+」/
  CHUUKI_COMMAND = "注記付き"
  TCY_COMMAND = "縦中横"
  KEIGAKOMI_COMMAND = "罫囲み"
  YOKOGUMI_COMMAND = "横組み"
  CAPTION_COMMAND = "キャプション"
  WARIGAKI_COMMAND = "割書"
  KAERITEN_COMMAND = "返り点"
  KUNTEN_OKURIGANA_COMMAND = "訓点送り仮名"
  MIDASHI_COMMAND = "見出し"
  OMIDASHI_COMMAND = "大見出し"
  NAKAMIDASHI_COMMAND = "中見出し"
  KOMIDASHI_COMMAND = "小見出し"
  DOGYO_OMIDASHI_COMMAND = "同行大見出し"
  DOGYO_NAKAMIDASHI_COMMAND = "同行中見出し"
  DOGYO_KOMIDASHI_COMMAND = "同行小見出し"
  MADO_OMIDASHI_COMMAND = "窓大見出し"
  MADO_NAKAMIDASHI_COMMAND = "窓中見出し"
  MADO_KOMIDASHI_COMMAND = "窓小見出し"
  LEFT_MARK = "左"
  UNDER_MARK = "下"
  OVER_MARK = "上"
  MAIN_MARK = "本文"
  END_MARK = "終わり"
  TEN_MARK = "点"
  SEN_MARK = "線"
  OPEN_MARK = "ここから"
  CLOSE_MARK = "ここで"
  MADE_MARK = "まで"
  DOGYO_MARK = "同行"
  MADO_MARK = "窓"
  JIAGE_COMMAND = "字上げ"
  JISAGE_COMMAND = "字下げ"
  PHOTO_COMMAND = "写真"
  ORIKAESHI_COMMAND = "折り返して"
  ONELINE_COMMAND = "この行"
  NON_0213_GAIJI = "非0213外字"
  WARICHU_COMMAND = "割り注"
  TENTSUKI_COMMAND = "天付き"
  PAT_REST_NOTES = /(左|下)に「(.*)」の(ルビ|注記|傍記)/
  PAT_KUTEN = /「※」[は|の]/
  PAT_KUTEN_DUAL = /※.*※/
  PAT_GAIJI = /(?:＃)(.*)(?:、)(.*)/
  PAT_KAERITEN = /^([一二三四五六七八九十レ上中下甲乙丙丁天地人]+)$/
  PAT_OKURIGANA = /^（(.+)）$/
  PAT_REMOVE_OKURIGANA = /[（）]/
  PAT_CHITSUKI = /(地付き|字上げ)(終わり)*$/
  PAT_ORIKAESHI_JISAGE = /折り返して(\d*)字下げ/
  PAT_ORIKAESHI_JISAGE2 = /(\d*)字下げ、折り返して(\d*)字下げ/
  PAT_JI_LEN = /([0-9]+)字/
  PAT_INLINE_RUBY = "「(.*)」の注記付き"
  PAT_IMAGE = /(.*)（(fig.+\.png)(、横([0-9]+)×縦([0-9]+))*）入る/
  PAT_FRONTREF = /「([^「」]*(?:「.+」)*[^「」]*)」[にはの](「.+」の)*(.+)/
  PAT_RUBY_DIR = /(左|下)に「([^」]*)」の(ルビ|注記)/
  PAT_CHUUKI = /「(.+?)」の注記/
  PAT_BOUKI = /「(.)」の傍記/
  PAT_CHARSIZE = /(.*)段階(..)な文字/

  DYNAMIC_CONTENTS = "<div id=\"card\">\r\n<hr />\r\n<br />\r\n" +
                     "<a href=\"JavaScript:goLibCard();\" id=\"goAZLibCard\">●図書カード</a>" +
                     "<script type=\"text/javascript\" src=\"../../contents.js\"></script>\r\n" +
                     "<script type=\"text/javascript\" src=\"../../golibcard.js\"></script>\r\n" +
                     "</div>"

  # KUNOJI = ["18e518f5"].pack("h*")
  # utf8 ["fecbf8fecbcb"].pack("h*")
  # DAKUTENKUNOJI = ["18e518d818f5"].pack("h*")
  # utf8 ["fecbf82e083bfecbcb"].pack("h*")

  loader = Aozora2Html::YamlLoader.new(File.dirname(__FILE__))
  ACCENT_TABLE = loader.load("../yml/accent_table.yml")

  # [class, tag]
  COMMAND_TABLE = loader.load("../yml/command_table.yml")
  JIS2UCS = loader.load("../yml/jis2ucs.yml")

  INDENT_TYPE = {
    :jisage => "字下げ",
    :chitsuki => "地付き",
    :midashi => "見出し",
    :jizume => "字詰め",
    :yokogumi => "横組み",
    :keigakomi => "罫囲み",
    :caption => "キャプション",
    :futoji => "太字",
    :shatai => "斜体",
    :dai => "大きな文字",
    :sho => "小さな文字",
  }

  DAKUTEN_KATAKANA_TABLE = {
    "2" => "ワ゛",
    "3" => "ヰ゛",
    "4" => "ヱ゛",
    "5" => "ヲ゛",
  }

  def initialize(input, output)
    if input.respond_to?(:read) ## readable IO?
      @stream = Jstream.new(input)
    else
      @stream = Jstream.new(File.open(input,"rb:Shift_JIS"))
    end
    if output.respond_to?(:print) ## writable IO?
      @out = output
    else
      @out = File.open(output,"w")
    end
    @buffer = []
    @ruby_buf = RubyBuffer.new
    @section = :head  ## 現在処理中のセクション(:head,:head_end,:chuuki,:chuuki_in,:body,:tail)
    @header = Aozora2Html::Header.new()  ## ヘッダ行の配列
    @style_stack = StyleStack.new  ##スタイルのスタック
    @chuuki_table = {} ## 最後にどの注記を出すかを保持しておく
    @images = []  ## 使用した外字の画像保持用
    @indent_stack = [] ## 基本はシンボルだが、ぶらさげのときはdivタグの文字列が入る
    @tag_stack = []
    @midashi_id = 0  ## 見出しのカウンタ、見出しの種類によって増分が異なる
    @terprip = true  ## 改行制御用 (terpriはLisp由来?)
    @endchar = :eof  ## 解析終了文字、AccentParserやTagParserでは異なる
    @noprint = nil  ## 行末を読み込んだとき、何も出力しないかどうかのフラグ
  end

  def line_number
    @stream.line
  end

  def block_allowed_context?
    # inline_tagが開いていないかチェックすれば十分
    @style_stack.empty?
  end

  # 一文字読み込む
  def read_char
    @stream.read_char
  end

  # 指定された終端文字(1文字のStringかCRLF)まで読み込む
  #
  #  @param [String] endchar 終端文字
  def read_to(endchar)
    buf = ""
    loop do
      char = @stream.read_char
      if char == endchar
        break
      else
        if char.kind_of?(Symbol)
          print endchar
        end
        buf.concat(char)
      end
    end
    buf
  end

  def read_accent
    Aozora2Html::AccentParser.new(@stream, ACCENT_END, @chuuki_table, @images).process
  end

  def read_to_nest(endchar)
    Aozora2Html::TagParser.new(@stream, endchar, @chuuki_table, @images).process
  end

  # 1行読み込み
  #
  # 合わせて@bufferもクリアする
  # @return [String] 読み込んだ文字列を返す
  #
  def read_line
    tmp = read_to("\r\n")
    @buffer = []
    tmp
  end

  # parseする
  #
  # 終了時（終端まで来た場合）にはthrow :terminateで脱出する
  #
  def process
    begin
      catch(:terminate) do
        loop do
          begin
            parse
          rescue Aozora2Html::Error => e
            puts e.message(line_number)
            if e.is_a?(Aozora2Html::Error)
              exit(2)
            end
          end
        end
      end
      tail_output # final call
      finalize
      close
    rescue => e
      puts "ERROR: line: #{line_number}"
      raise e
    end
  end

  def char_type(char)
    begin
      ## `String#char_type`も定義されているのに注意
      char.char_type
    rescue
      :else
    end
  end

  def finalize
    hyoki
    dynamic_contents
    @out.print("</body>\r\n</html>\r\n")
  end

  def dynamic_contents
    @out.print DYNAMIC_CONTENTS
  end

  def close
    @stream.close
    @out.close
  end

  # 記法のシンボル名から文字列へ変換する
  # シンボルが見つからなければそのまま返す
  def convert_indent_type(type)
    INDENT_TYPE[type] || type
  end

  def check_close_match(type)
    ind = if @indent_stack.last.is_a?(String)
            @noprint = true
            :jisage
          else
            @indent_stack.last
          end
    if ind == type
      nil
    else
      convert_indent_type(type)
    end
  end

  def implicit_close(type)
    if @indent_stack.last
      if check_close_match(type)
        # ok, nested multiline tags, go ahead
      else
        # not nested, please close
        @indent_stack.pop
        if tag = @tag_stack.pop
          push_chars(tag)
        end
      end
    end
  end

  # 本文が終わってよいかチェックし、終わっていなければ例外をあげる
  def ensure_close
    if n = @indent_stack.last
      raise Aozora2Html::Error, I18n.t(:terminate_in_style, convert_indent_type(n))
    end
  end

  def explicit_close(type)
    n = check_close_match(type)
    if n
      raise Aozora2Html::Error, I18n.t(:invalid_closing, n, n)
    end
    if tag = @tag_stack.pop
      push_chars(tag)
    end
  end

  # main loop
  def parse
    case @section
    when :head
      parse_header
    when :head_end
      judge_chuuki
    when :chuuki, :chuuki_in
      parse_chuuki
    when :body
      parse_body
    when :tail
      parse_tail
    else
      raise Aozora2Html::Error, "encount undefined condition"
    end
  end

  def judge_chuuki
    # 注記が入るかどうかチェック
    i = 0
    loop do
      case @stream.peek_char(i)
      when "-"
        i += 1
      when "\r\n"
        if i == 0 && @stream.peek_char(1) == "\r\n"
          @section = :body
        else
          @section = :chuuki
        end
        return
      else
        @section = :body
        @out.print("<br />\r\n")
        return
      end
    end
  end

  # headerは一行ずつ読む
  def parse_header
    string = read_line
    # refine from Tomita 09/06/14
    if string == ""  # 空行がくれば、そこでヘッダー終了とみなす
      @section = :head_end
      @out.print @header.to_html
    else
      string.gsub!(RUBY_PREFIX,"")
      string.gsub!(PAT_RUBY,"")
      @header.push(string)
    end
  end

  def parse_chuuki
    string = read_line
    if string.match(/^\-+$/)
      case @section
      when :chuuki
        @section = :chuuki_in
      when :chuuki_in
        @section = :body
      end
    end
  end

  # 使うべきではない文字があるかチェックする
  #
  # 警告を出力するだけで結果には影響を与えない。警告する文字は以下:
  #
  # * 1バイト文字
  # * `＃`ではなく`♯`
  # * JIS(JIS X 0208)外字
  #
  # @return [void]
  #
  def illegal_char_check(char, line)
    if char.is_a?(String)
      code = char.unpack("H*")[0]
      if code == "21" or
          code == "23" or
          ("a1" <= code and code <= "a5") or
          ("28" <= code and code <= "29") or
          code == "5b" or
          code == "5d" or
          code == "3d" or
          code == "3f" or
          code == "2b" or
          ("7b" <= code and code <= "7d")
        puts I18n.t(:warn_onebyte, line, char)
      end

      if code == "81f2"
        puts I18n.t(:warn_chuki, line, char)
      end

      if ("81ad" <=  code and code <= "81b7") or
          ("81c0" <=  code and code <= "81c7") or
          ("81cf" <=  code and code <= "81d9") or
          ("81e9" <=  code and code <= "81ef") or
          ("81f8" <=  code and code <= "81fb") or
          ("8240" <=  code and code <= "824e") or
          ("8259" <=  code and code <= "825f") or
          ("827a" <=  code and code <= "8280") or
          ("829b" <=  code and code <= "829e") or
          ("82f2" <=  code and code <= "82fc") or
          ("8397" <=  code and code <= "839e") or
          ("83b7" <=  code and code <= "83be") or
          ("83d7" <=  code and code <= "83fc") or
          ("8461" <=  code and code <= "846f") or
          ("8492" <=  code and code <= "849e") or
          ("84bf" <=  code and code <= "84fc") or
          ("8540" <=  code and code <= "85fc") or
          ("8640" <=  code and code <= "86fc") or
          ("8740" <=  code and code <= "87fc") or
          ("8840" <=  code and code <= "889e") or
          ("9873" <=  code and code <= "989e") or
          ("eaa5" <=  code and code <= "eafc") or
          ("eb40" <=  code and code <= "ebfc") or
          ("ec40" <=  code and code <= "ecfc") or
          ("ed40" <=  code and code <= "edfc") or
          ("ee40" <=  code and code <= "eefc") or
          ("ef40" <=  code and code <= "effc")
        puts I18n.t(:warn_jis_gaiji, line, char)
      end
    end
  end

  # 本体解析部
  #
  # 1文字ずつ読み込み、dispatchして@buffer,@ruby_bufへしまう
  # 改行コードに当たったら溜め込んだものをgeneral_outputする
  #
  def parse_body
    char = read_char
    check = true
    case char
    when ACCENT_BEGIN
      check = false
      char = read_accent
    when TEIHON_MARK[0]
      if @buffer.length == 0
        ending_check
      end
    when GAIJI_MARK
      char = dispatch_gaiji
    when COMMAND_BEGIN
      char = dispatch_aozora_command
    when KU
      assign_kunoji
    when RUBY_BEGIN_MARK
      char = apply_ruby
    end

    case char
    when "\r\n"
      general_output
    when RUBY_PREFIX
      @ruby_buf.dump_into(@buffer)
      @ruby_buf.protected = true
    when @endchar
      # suddenly finished the file
      puts I18n.t(:warn_unexpected_terminator, line_number)
      throw :terminate
    when nil
      # noop
    else
      if check
        illegal_char_check(char, line_number)
      end
      push_chars(char)
    end
  end

  # 本文が終了したかどうかチェックする
  #
  #
  def ending_check
    # `底本：`でフッタ(:tail)に遷移
    if @stream.peek_char(0) == TEIHON_MARK[1] and @stream.peek_char(1) == TEIHON_MARK[2]
      @section = :tail
      ensure_close
      @out.print "</div>\r\n<div class=\"bibliographical_information\">\r\n<hr />\r\n<br />\r\n"
    end
  end

  # Original Aozora2Html#push_chars does not convert "'" into '&#39;'; it's old behaivor
  # of CGI.escapeHTML().
  #
  def push_chars(obj)
    if obj.is_a?(Array)
      obj.each do |x|
        push_chars(x)
      end
    elsif obj.is_a?(String)
      if obj.length == 1
        obj = obj.gsub(/[&\"<>]/, {'&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;'})
      end
      obj.each_char do |x|
        push_char(x)
      end
    else
      push_char(obj)
    end
  end

  def push_char(char)
    ctype = char_type(char)
    if ctype == :hankaku_terminate and @ruby_buf.char_type == :hankaku
      if @ruby_buf.last_is_string?
        @ruby_buf.last_concat(char)
      else
        @ruby_buf.push(char)
      end
      @ruby_buf.char_type = :else
    elsif @ruby_buf.protected or (ctype != :else and ctype == @ruby_buf.char_type)
      if char.is_a?(String) and @ruby_buf.last_is_string?
        @ruby_buf.last_concat(char)
      else
        @ruby_buf.push(char)
        @ruby_buf.push("")
      end
    else
      @ruby_buf.dump_into(@buffer)
      @ruby_buf.clear(char)
      @ruby_buf.char_type = ctype
    end
  end

  # 行出力時に@bufferが空かどうか調べる
  #
  # @bufferの中身によって行末の出力が異なるため
  #
  # @return [true, false, :inline] 空文字ではない文字列が入っていればfalse、1行注記なら:inline、それ以外しか入っていなければtrue
  #
  def buf_is_blank?(buf)
    buf.each do |token|
      if token.is_a?(String) and token != ""
        return false
      elsif token.is_a?(Aozora2Html::Tag::OnelineIndent)
        return :inline
      end
    end
    true
  end

  # 行末で<br />を出力するべきかどうかの判別用
  #
  # @return [true, false] Multilineの注記しか入っていなければfalse、Multilineでも空文字でもない要素が含まれていればtrue
  #
  def terpri?(buf)
    flag = true
    buf.each do |x|
      if x.is_a?(Aozora2Html::Tag::Multiline)
        flag = false
      elsif x == ""
        # skip
      else
        return true
      end
    end
    flag
  end

  # 読み込んだ行の出力を行う
  #
  # parserが改行文字を読み込んだら呼ばれる。
  # 最終的に@ruby_bufと@bufferは初期化する
  #
  # @return [void]
  #
  def general_output
    if @style_stack.last
      raise Aozora2Html::Error, I18n.t(:dont_crlf_in_style, @style_stack.last_command)
    end
    # bufferにインデントタグだけがあったら改行しない！
    if @noprint
      @noprint = false
      return
    end
    @ruby_buf.dump_into(@buffer)
    buf = @buffer
    @ruby_buf.clear
    @buffer = []
    tail = []

    indent_type = buf_is_blank?(buf)
    terprip = (terpri?(buf) and @terprip)
    @terprip = true

    if @indent_stack.last.is_a?(String) and !indent_type
      @out.print @indent_stack.last
    end

    buf.each do |s|
      if s.is_a?(Aozora2Html::Tag::OnelineIndent)
        tail.unshift(s.close_tag)
      elsif s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) and !s.escaped?
        # 消してあった※を復活させて
        @out.print GAIJI_MARK
      end
      @out.print s.to_s
    end

    # 最後はCRLFを出力する
    if @indent_stack.last.is_a?(String)
      # ぶら下げindent
      # tail always active
      @out.print tail.map{|s| s.to_s}.join("")
      if indent_type == :inline
        @out.print "\r\n"
      elsif indent_type and terprip
        @out.print "<br />\r\n"
      else
        @out.print "</div>\r\n"
      end
    elsif tail.empty? and terprip
      @out.print "<br />\r\n"
    else
      @out.print tail.map{|s| s.to_s}.join("")
      @out.print "\r\n"
    end
  end

  # 前方参照の発見 Ruby,style重ねがけ等々のため、要素の配列で返す
  #
  # 前方参照は`○○［＃「○○」に傍点］`、`吹喋［＃「喋」に「ママ」の注記］`といった表記
  def search_front_reference(string)
    if string.length == 0
      return false
    end
    searching_buf = if @ruby_buf.present?
                      @ruby_buf.to_a
                    else
                      @buffer
                    end
    last_string = searching_buf.last
    if last_string.is_a?(String)
      if last_string == ""
        searching_buf.pop
        search_front_reference(string)
      elsif last_string.match(Regexp.new(Regexp.quote(string)+"$"))
        # 完全一致
        # start = match.begin(0)
        # tail = match.end(0)
        # last_string[start,tail-start] = ""
        searching_buf.pop
        searching_buf.push(last_string.sub(Regexp.new(Regexp.quote(string)+"$"),""))
        [string]
      elsif string.match(Regexp.new(Regexp.quote(last_string)+"$"))
        # 部分一致
        tmp = searching_buf.pop
        found = search_front_reference(string.sub(Regexp.new(Regexp.quote(last_string)+"$"),""))
        if found
          found+[tmp]
        else
          searching_buf.push(tmp)
          false
        end
      end
    elsif last_string.is_a?(Aozora2Html::Tag::ReferenceMentioned)
      inner = last_string.target_string
      if inner == string
        # 完全一致
        searching_buf.pop
        [last_string]
      elsif string.match(Regexp.new(Regexp.quote(inner)+"$"))
        # 部分一致
        tmp = searching_buf.pop
        found = search_front_reference(string.sub(Regexp.new(Regexp.quote(inner)+"$"),""))
        if found
          found+[tmp]
        else
          searching_buf.push(tmp)
          false
        end
      end
    else
      false
    end
  end

  # 発見した前方参照を元に戻す
  #
  # @ruby_bufがあれば@ruby_bufに、なければ@bufferにpushする
  # バッファの最後と各要素が文字列ならconcatし、どちらが文字列でなければ（concatできないので）pushする
  #
  # @return [void]
  #
  def recovery_front_reference(reference)
    reference.each do |elt|
#      if @ruby_buf.protected
      if @ruby_buf.present?
        if @ruby_buf.last_is_string? && elt.is_a?(String)
          @ruby_buf.last_concat(elt)
        else
          @ruby_buf.push(elt)
        end
      elsif @buffer.last.is_a?(String)
        if elt.is_a?(String)
          @buffer.last.concat(elt)
        else
          @buffer.push(elt)
        end
      else
        @ruby_buf.push(elt)
      end
    end
  end

  def kuten2png(substring)
    desc = substring.gsub(PAT_KUTEN,"")
    match = desc.match(/[12]\-\d{1,2}\-\d{1,2}/)
    if match and !desc.match(NON_0213_GAIJI) and !desc.match(PAT_KUTEN_DUAL)
      @chuuki_table[:newjis] = true
      codes = match[0].split("-")
      folder = sprintf("%1d-%02d", codes[0], codes[1])
      code = sprintf("%1d-%02d-%02d",*codes)
      Aozora2Html::Tag::EmbedGaiji.new(self, folder, code, desc.gsub!(IGETA_MARK,""))
    else
      substring
    end
  end

  def escape_gaiji(command)
    _whole, kanji, line = command.match(PAT_GAIJI).to_a
    tmp = @images.assoc(kanji)
    if tmp
      tmp.push(line)
    else
      @images.push([kanji, line])
    end
    Aozora2Html::Tag::UnEmbedGaiji.new(self, command)
  end

  def dispatch_gaiji
    # 「※」の次が「［」でなければ外字ではない
    if @stream.peek_char(0) !=  COMMAND_BEGIN
      return GAIJI_MARK
    end

    # 「［」を読み捨てる
    _ = read_char
    # embed?
    command, _raw = read_to_nest(COMMAND_END)
    try_emb = kuten2png(command)
    if try_emb != command
      try_emb
    elsif command.match(/U\+([0-9A-F]{4,5})/) && Aozora2Html::Tag::EmbedGaiji.use_unicode
      unicode_num = $1
      Aozora2Html::Tag::EmbedGaiji.new(self, nil, nil, command, unicode_num)
    else
      # Unemb
      escape_gaiji(command)
    end
  end

  # 注記記法の場合分け
  def dispatch_aozora_command
    # 「［」の次が「＃」でなければ注記ではない
    if @stream.peek_char(0) != IGETA_MARK
      return COMMAND_BEGIN
    end

    # 「＃」を読み捨てる
    _ = read_char
    command,raw = read_to_nest(COMMAND_END)
    # 適用順序はこれで大丈夫か？　誤爆怖いよ誤爆
    if command.match(ORIKAESHI_COMMAND)
      apply_burasage(command)

    elsif command.start_with?(OPEN_MARK)
      exec_block_start_command(command)
    elsif command.start_with?(CLOSE_MARK)
      exec_block_end_command(command)

    elsif command.match(WARICHU_COMMAND)
      apply_warichu(command)
    elsif command.match(JISAGE_COMMAND)
      apply_jisage(command)
    elsif command.match(/fig(\d)+_(\d)+\.png/)
      exec_img_command(command,raw)
    # avoid to try complex ruby -- escape to notes
    elsif command.match(PAT_REST_NOTES)
      apply_rest_notes(command)
    elsif command.end_with?(END_MARK)
      exec_inline_end_command(command)
      nil
    elsif command.match(PAT_REF)
      exec_frontref_command(command)
    elsif command.match(/1-7-8[2345]/)
      apply_dakuten_katakana(command)
    elsif command.match(PAT_KAERITEN)
      Aozora2Html::Tag::Kaeriten.new(self, command)
    elsif command.match(PAT_OKURIGANA)
      Aozora2Html::Tag::Okurigana.new(self, command.gsub!(PAT_REMOVE_OKURIGANA,""))
    elsif command.match(PAT_CHITSUKI)
      apply_chitsuki(command)
    elsif exec_inline_start_command(command)
      nil
    else
      apply_rest_notes(command)
    end
  end

  def apply_burasage(command)
    tag = nil
    if implicit_close(:jisage)
      @terprip = false
      general_output
    end
    @noprint = true # always no print
    command = Utils.convert_japanese_number(command)
    if command.match(TENTSUKI_COMMAND)
      width = command.match(PAT_ORIKAESHI_JISAGE)[1]
      tag = '<div class="burasage" style="margin-left: ' + width + 'em; text-indent: -' + width  + 'em;">'
    else
      match = command.match(PAT_ORIKAESHI_JISAGE2)
      left, indent = match.to_a[1,2]
      left = left.to_i - indent.to_i
      tag = "<div class=\"burasage\" style=\"margin-left: #{indent}em; text-indent: #{left}em;\">"
    end
    @indent_stack.push(tag)
    @tag_stack.push("") # dummy
    nil
  end

  def jisage_width(command)
    Utils.convert_japanese_number(command).match(/(\d*)(?:#{JISAGE_COMMAND})/)[1]
  end

  def apply_jisage(command)
    if command.match(MADE_MARK) or command.match(END_MARK)
      # 字下げ終わり
      explicit_close(:jisage)
      @indent_stack.pop
      nil
    elsif command.match(ONELINE_COMMAND)
      # 1行だけ
      @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
      nil
    elsif @buffer.length == 0 and @stream.peek_char(0) == "\r\n"
      # commandのみ
      @terprip = false
      implicit_close(:jisage)
      # adhook hack
      @noprint = false
      @indent_stack.push(:jisage)
      Aozora2Html::Tag::MultilineJisage.new(self, jisage_width(command))
    else
      @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
      nil
    end
  end

  def apply_warichu(command)
    if command.match(END_MARK)
      if @stream.peek_char(0) != PAREN_END_MARK
        push_chars(PAREN_END_MARK)
      end
      push_chars('</span>')
    else
      check = @ruby_buf.last
      push_chars('<span class="warichu">')
      unless check.is_a?(String) and check.end_with?(PAREN_BEGIN_MARK)
        push_chars(PAREN_BEGIN_MARK)
      end
    end
    nil
  end

  def chitsuki_length(command)
    command = Utils.convert_japanese_number(command)
    if match = command.match(PAT_JI_LEN)
      match[1]
    else
      "0"
    end
  end

  def apply_chitsuki(string, multiline = false)
    if string.match(CLOSE_MARK+INDENT_TYPE[:chitsuki]+END_MARK) or
        string.match(CLOSE_MARK+JIAGE_COMMAND+END_MARK)
      explicit_close(:chitsuki)
      @indent_stack.pop
      nil
    else
      len = chitsuki_length(string)
      if multiline
        # 複数行指定
        implicit_close(:chitsuki)
        @indent_stack.push(:chitsuki)
        Aozora2Html::Tag::MultilineChitsuki.new(self, len)
      else
        # 1行のみ
        Aozora2Html::Tag::OnelineChitsuki.new(self, len)
      end
    end
  end

  def new_midashi_id(size)
    if size.kind_of?(Integer)
      @midashi_id += size
      return @midashi_id
    end

    case size
    when /#{SIZE_SMALL}/
      inc = 1
    when /#{SIZE_MIDDLE}/
      inc = 10
    when /#{SIZE_LARGE}/
      inc = 100
    else
      raise Aozora2Html::Error, I18n.t(:undefined_header)
    end
    @midashi_id += inc
  end

  def apply_midashi(command)
    @indent_stack.push(:midashi)
    if command.match(DOGYO_MARK)
      midashi_type = :dogyo
    elsif command.match(MADO_MARK)
      midashi_type = :mado
    else
      midashi_type = :normal
      @terprip = false
    end
    Aozora2Html::Tag::MultilineMidashi.new(self, command, midashi_type)
  end

  def apply_yokogumi(command)
    @indent_stack.push(:yokogumi)
    Aozora2Html::Tag::MultilineYokogumi.new(self)
  end

  def apply_keigakomi(command)
    @indent_stack.push(:keigakomi)
    Aozora2Html::Tag::Keigakomi.new(self)
  end

  def apply_caption(command)
    @indent_stack.push(:caption)
    Aozora2Html::Tag::MultilineCaption.new(self)
  end

  def apply_jizume(command)
    w = Utils.convert_japanese_number(command).match(/(\d*)(?:#{INDENT_TYPE[:jizume]})/)[1]
    @indent_stack.push(:jizume)
    Aozora2Html::Tag::Jizume.new(self, w)
  end

  def push_block_tag(tag,closing)
    push_chars(tag)
    closing.concat(tag.close_tag)
  end

  def detect_style_size(style)
    if style.match("小")
      :sho
    else
      :dai
    end
  end

  def exec_inline_start_command(command)
    case command
    when CHUUKI_COMMAND
      @style_stack.push([command,'</ruby>'])
      push_char('<ruby><rb>')
    when TCY_COMMAND
      @style_stack.push([command,'</span>'])
      push_char('<span dir="ltr">')
    when KEIGAKOMI_COMMAND
      @style_stack.push([command,'</span>'])
      push_chars('<span class="keigakomi">')
    when YOKOGUMI_COMMAND
      @style_stack.push([command,'</span>'])
      push_chars('<span class="yokogumi">')
    when CAPTION_COMMAND
      @style_stack.push([command,'</span>'])
      push_chars('<span class="caption">')
    when WARIGAKI_COMMAND
      @style_stack.push([command,'</span>'])
      push_chars('<span class="warigaki">')
    when OMIDASHI_COMMAND
      @style_stack.push([command,'</a></h3>'])
      @terprip = false
      push_chars("<h3 class=\"o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when NAKAMIDASHI_COMMAND
      @style_stack.push([command,'</a></h4>'])
      @terprip = false
      push_chars("<h4 class=\"naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when KOMIDASHI_COMMAND
      @style_stack.push([command,'</a></h5>'])
      @terprip = false
      push_chars("<h5 class=\"ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    when DOGYO_OMIDASHI_COMMAND
      @style_stack.push([command,'</a></h3>'])
      push_chars("<h3 class=\"dogyo-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when DOGYO_NAKAMIDASHI_COMMAND
      @style_stack.push([command,'</a></h4>'])
      push_chars("<h4 class=\"dogyo-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when DOGYO_KOMIDASHI_COMMAND
      @style_stack.push([command,'</a></h5>'])
      push_chars("<h5 class=\"dogyo-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    when MADO_OMIDASHI_COMMAND
      @style_stack.push([command,'</a></h3>'])
      push_chars("<h3 class=\"mado-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when MADO_NAKAMIDASHI_COMMAND
      @style_stack.push([command,'</a></h4>'])
      push_chars("<h4 class=\"mado-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when MADO_KOMIDASHI_COMMAND
      @style_stack.push([command,'</a></h5>'])
      push_chars("<h5 class=\"mado-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    when PAT_CHARSIZE
      @style_stack.push([command,'</span>'])
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      times = Utils.convert_japanese_number(nest).to_i
      daisho = detect_style_size(style)
      html_class = daisho.to_s + times.to_s
      size = Utils.create_font_size(times, daisho)
      push_chars("<span class=\"#{html_class}\" style=\"font-size: #{size};\">")
    else
      ## Decoration ##
      key = command
      filter = lambda{|x| x}
      if command.match(PAT_DIRECTION)
        _whole, dir, com = command.match(PAT_DIRECTION).to_a
        # renew command
        key = com
        if command.match(TEN_MARK)
          case dir
          when LEFT_MARK, UNDER_MARK
            filter = lambda{|x| x + "_after"}
          end
        elsif command.match(SEN_MARK)
          case dir
          when LEFT_MARK, OVER_MARK
            filter = lambda{|x| x.sub("under","over")}
          end
        end
      end

      found = COMMAND_TABLE[key]
      # found = [class, tag]
      if found
        @style_stack.push([command,"</#{found[1]}>"])
        push_chars("<#{found[1]} class=\"#{filter.call(found[0])}\">")
      else
        if $DEBUG
          puts I18n.t(:warn_undefined_command, line_number, key)
        end
        nil
      end
    end
  end

  def exec_inline_end_command(command)
    encount = command.sub(END_MARK,"")
    if encount == MAIN_MARK
      # force to finish main_text
      @section = :tail
      ensure_close
      @noprint = true
      @out.print "</div>\r\n<div class=\"after_text\">\r\n<hr />\r\n"
    elsif encount.match(CHUUKI_COMMAND) and @style_stack.last_command == CHUUKI_COMMAND
      # special inline ruby
      @style_stack.pop
      _whole, ruby = encount.match(PAT_INLINE_RUBY).to_a
      push_char("</rb><rp>（</rp><rt>#{ruby}</rt><rp>）</rp></ruby>")
    elsif @style_stack.last_command.match(encount)
      push_chars(@style_stack.pop[1])
    else
      raise Aozora2Html::Error, I18n.t(:invalid_nesting, encount, @style_stack.last_command)
    end
  end

  def exec_block_start_command(command)
    original_command = command.dup
    command.sub!(/^#{OPEN_MARK}/, "")
    match = ""
    if command.match(INDENT_TYPE[:jisage])
      push_block_tag(apply_jisage(command),match)
    elsif command.match(/(#{INDENT_TYPE[:chitsuki]}|#{JIAGE_COMMAND})$/)
      push_block_tag(apply_chitsuki(command,true),match)
    end

    if command.match(INDENT_TYPE[:midashi])
      push_block_tag(apply_midashi(command),match)
    end

    if command.match(INDENT_TYPE[:jizume])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_jizume(command),match)
    end

    if command.match(INDENT_TYPE[:yokogumi])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_yokogumi(command),match)
    end

    if command.match(INDENT_TYPE[:keigakomi])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_keigakomi(command),match)
    end

    if command.match(INDENT_TYPE[:caption])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_caption(command),match)
    end

    if command.match(INDENT_TYPE[:futoji])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, "futoji"),match)
      @indent_stack.push(:futoji)
    end
    if command.match(INDENT_TYPE[:shatai])
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, "shatai"),match)
      @indent_stack.push(:shatai)
    end

    if command.match(PAT_CHARSIZE)
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      if match != ""
        @indent_stack.pop
      end
      daisho = detect_style_size(style)
      push_block_tag(Aozora2Html::Tag::FontSize.new(self,
                                                    Utils.convert_japanese_number(nest).to_i,
                                                    daisho),
                     match)
      @indent_stack.push(daisho)
    end

    if match == ""
      apply_rest_notes(original_command)
    else
      @tag_stack.push(match)
      nil
    end
  end

  # コマンド文字列からモードのシンボルを取り出す
  #
  # @return [Symbol]
  #
  def detect_command_mode(command)
    if command.match(INDENT_TYPE[:chitsuki]+END_MARK) || command.match(JIAGE_COMMAND+END_MARK)
      return :chitsuki
    end
    INDENT_TYPE.keys.each do |key|
      if command.match(INDENT_TYPE[key])
        return key
      end
    end
    return nil
  end

  def exec_block_end_command(command)
    original_command = command.dup
    command.sub!(/^#{CLOSE_MARK}/, "")
    match = false
    mode = detect_command_mode(command)
    if mode
      explicit_close(mode)
      match = @indent_stack.pop
    end

    if match
      if !match.is_a?(String)
        @terprip = false
      end
      nil
    else
      apply_rest_notes(original_command)
    end
  end

  def exec_img_command(command,raw)
    match = raw.match(PAT_IMAGE)
    if match
      _whole, alt, src, _wh, width, height = match.to_a
      css_class = if alt.match(PHOTO_COMMAND)
                    "photo"
                  else
                    "illustration"
                  end
      Aozora2Html::Tag::Img.new(self, src, css_class, alt, width, height)
    else
      apply_rest_notes(command)
    end
  end

  def exec_frontref_command(command)
    _whole, reference, spec1, spec2 = command.match(PAT_FRONTREF).to_a
    if spec1
      spec = spec1 + spec2
    else
      spec = spec2
    end
    if reference and found = search_front_reference(reference)
      tmp = exec_style(found, spec)
      if tmp
        return tmp
      else
        recovery_front_reference(found)
      end
    end
    # comment out?
    apply_rest_notes(command)
  end

  # 傍記を並べる用
  #
  def multiply(bouki, times)
    sep = "&nbsp;"
    ([bouki]*times).join(sep)
  end

  # arrayがルビを含んでいればそのインデックスを返す
  #
  # @return [Integer, nil]
  #
  def include_ruby?(array)
    array.index do |elt|
      if elt.is_a?(Aozora2Html::Tag::Ruby)
        true
      elsif elt.is_a?(Aozora2Html::Tag::ReferenceMentioned)
        if elt.target.is_a?(Array)
          include_ruby?(elt.target)
        else
          elt.target.is_a?(Aozora2Html::Tag::Ruby)
        end
      end
    end
  end

  # rubyタグの再生成(本体はrearrange_ruby)
  #
  # complex ruby wrap up utilities -- don't erase! we will use soon ...
  #
  def rearrange_ruby_tag(targets, upper_ruby, under_ruby = "")
    target, upper, under = rearrange_ruby(targets, upper_ruby, under_ruby)
    Aozora2Html::Tag::Ruby.new(self, target, upper, under)
  end

  # rubyタグの再割り当て
  def rearrange_ruby(targets, upper_ruby, under_ruby = "")
    if include_ruby?(targets)
      new_targets = []
      new_upper = if upper_ruby != ""
                    upper_ruby
                  else
                    []
                  end
      new_under = if under_ruby != ""
                    under_ruby
                  else
                    []
                  end
      if new_upper.length > 1 and new_under.length > 1
        raise Aozora2Html::Error, I18n.t(:dont_allow_triple_ruby)
      end

      targets.each{|x|
        if x.is_a?(Aozora2Html::Tag::Ruby)
          if x.target.is_a?(Array)
            # inner Aozora2Html::Tag::Ruby is already complex ... give up
            raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
          else
            if x.ruby != ""
              if new_upper.is_a?(Array)
                new_upper.push(x.ruby)
              else
                raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
              end
            else
              if new_under.is_a?(Array)
                new_under.push(x.under_ruby)
              else
                raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
              end
            end
            new_targets.push(x.target)
          end
        elsif x.is_a?(Aozora2Html::Tag::ReferenceMentioned)
          if x.target.is_a?(Array)
            # recursive
            tar,up,un = rearrange_ruby(x.target, "", "")
            # rotation!!
            tar.each{|y|
              tmp = x.dup
              tmp.target = y
              new_targets.push(tmp)}
            if new_under.is_a?(Array)
              new_under.concat(un)
            elsif un.to_s.length > 0
              raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
            end
            if new_upper.is_a?(Array)
              new_upper.concat(up)
            elsif up.to_s.length > 0
              raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
            end
          else
            new_targets.push(x)
            if new_under.is_a?(Array)
              new_under.push("")
            end
            if new_upper.is_a?(Array)
              new_upper.push("")
            end
          end
        else
          new_targets.push(x)
          if new_under.is_a?(Array)
            new_under.push("")
          end
          if new_upper.is_a?(Array)
            new_upper.push("")
          end
        end
      }
      [new_targets, new_upper, new_under]
    else
      [targets, upper_ruby, under_ruby]
    end
  end

  def exec_style(targets, command)
    try_kuten = kuten2png(command)
    if try_kuten != command
      try_kuten
    elsif command.match(TCY_COMMAND)
      Aozora2Html::Tag::Dir.new(self, targets)
    elsif command.match(YOKOGUMI_COMMAND)
      Aozora2Html::Tag::InlineYokogumi.new(self, targets)
    elsif command.match(KEIGAKOMI_COMMAND)
      Aozora2Html::Tag::InlineKeigakomi.new(self, targets)
    elsif command.match(CAPTION_COMMAND)
      Aozora2Html::Tag::InlineCaption.new(self, targets)
    elsif command.match(KAERITEN_COMMAND)
      Aozora2Html::Tag::Kaeriten.new(self, targets)
    elsif command.match(KUNTEN_OKURIGANA_COMMAND)
      Aozora2Html::Tag::Okurigana.new(self, targets)
    elsif command.match(MIDASHI_COMMAND)
      midashi_type = :normal
      if command.match(DOGYO_MARK)
        midashi_type = :dogyo
      elsif command.match(MADO_MARK)
        midashi_type = :mado
      else
        @terprip = false
      end
      Aozora2Html::Tag::Midashi.new(self, targets, command, midashi_type)
    elsif command.match(PAT_CHARSIZE)
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      Aozora2Html::Tag::InlineFontSize.new(self,targets,
                                           Utils.convert_japanese_number(nest).to_i,
                                           detect_style_size(style))
    elsif command.match(PAT_RUBY_DIR)
      _whole, _dir, under = command.match(PAT_RUBY_DIR).to_a
      if targets.length == 1 and targets[0].is_a?(Aozora2Html::Tag::Ruby)
        tag = targets[0]
        if tag.under_ruby == ""
          tag.under_ruby = under
          tag
        else
          raise Aozora2Html::Error, I18n.t(:dont_allow_triple_ruby)
        end
      else
        rearrange_ruby_tag(targets, "", under)
      end
    elsif command.match(PAT_CHUUKI)
      rearrange_ruby_tag(targets, PAT_CHUUKI.match(command).to_a[1])
    elsif command.match(PAT_BOUKI)
      rearrange_ruby_tag(targets, multiply(PAT_BOUKI.match(command).to_a[1], targets.to_s.length))
    else
      ## direction fix! ##
      filter = lambda{|x| x}
      if command.match(PAT_DIRECTION)
        _whole, dir, com = command.match(PAT_DIRECTION).to_a
        # renew command
        command = com
        if command.match(TEN_MARK)
          case dir
          when LEFT_MARK, UNDER_MARK
            filter = lambda{|x| x + "_after"}
          end
        elsif command.match(SEN_MARK)
          case dir
          when LEFT_MARK, OVER_MARK
            filter = lambda{|x| x.sub("under","over")}
          end
        end
      end

      found = COMMAND_TABLE[command]
      # found = [class, tag]
      if found
        Aozora2Html::Tag::Decorate.new(self, targets, filter.call(found[0]), found[1])
      else
        nil
      end
    end
  end

  def apply_dakuten_katakana(command)
    n = command.match(/1-7-8([2345])/).to_a[1]
    frontref = DAKUTEN_KATAKANA_TABLE[n]
    if found = search_front_reference(frontref)
      Aozora2Html::Tag::DakutenKatakana.new(self, n,found.join)
    else
      apply_rest_notes(command)
    end
  end

  # くの字点の処理
  #
  # くの字点は現状そのまま出力するのでフッタの「表記について」で出力するかどうかのフラグ処理だけ行う
  def assign_kunoji
    second = @stream.peek_char(0)
    case second
    when NOJI
      @chuuki_table[:kunoji] = true
    when DAKUTEN
      if @stream.peek_char(1) == NOJI
        @chuuki_table[:dakutenkunoji] = true
      end
    end
  end

  def apply_rest_notes(command)
    @chuuki_table[:chuki] = true
    Aozora2Html::Tag::EditorNote.new(self, command)
  end

  # ｜が来たときは文字種を無視してruby_bufを守らなきゃいけない
  def apply_ruby
    @ruby_buf.protected = nil
    ruby, _raw = read_to_nest(RUBY_END_MARK)
    if ruby.length == 0
      # escaped ruby character
      return RUBY_BEGIN_MARK+RUBY_END_MARK
    end
    ans = ""
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
    @buffer.push(Aozora2Html::Tag::Ruby.new(self, ans, ruby))
    @buffer += notes
    @ruby_buf.clear
    nil
  end

  # parse_bodyのフッタ版
  def parse_tail
    char = read_char
    check = true
    case char
    when ACCENT_BEGIN
      check = false
      char = read_accent
    when @endchar
      throw :terminate
    when GAIJI_MARK
      char = dispatch_gaiji
    when COMMAND_BEGIN
      char = dispatch_aozora_command
    when KU
      assign_kunoji
    when RUBY_BEGIN_MARK
      char = apply_ruby
    end

    case char
    when "\r\n"
      tail_output
    when RUBY_PREFIX
      @ruby_buf.dump_into(@buffer)
      @ruby_buf.protected = true
    when nil
      # noop
    else
      if check
        illegal_char_check(char, line_number)
      end
      push_chars(char)
    end
  end

  # general_outputのフッタ版
  def tail_output
    @ruby_buf.dump_into(@buffer)
    string = @buffer.join
    @ruby_buf.clear
    @buffer = []
    string.gsub!("info@aozora.gr.jp",'<a href="mailto: info@aozora.gr.jp">info@aozora.gr.jp</a>')
    string.gsub!("青空文庫（http://www.aozora.gr.jp/）"){"<a href=\"http://www.aozora.gr.jp/\">#{$&}</a>"}
    if string.match(/(<br \/>$|<\/p>$|<\/h\d>$|<div.*>$|<\/div>$|^<[^>]*>$)/)
      @out.print string, "\r\n"
    else
      @out.print string, "<br />\r\n"
    end
  end

  # `●表記について`で使用した注記等を出力する
  def hyoki
    # <br /> times fix
    @out.print "<br />\r\n</div>\r\n<div class=\"notation_notes\">\r\n<hr />\r\n<br />\r\n●表記について<br />\r\n<ul>\r\n"
    @out.print "\t<li>このファイルは W3C 勧告 XHTML1.1 にそった形式で作成されています。</li>\r\n"
    if @chuuki_table[:chuki]
      @out.print "\t<li>［＃…］は、入力者による注を表す記号です。</li>\r\n"
    end
    if @chuuki_table[:kunoji]
      if @chuuki_table[:dakutenkunoji]
        @out.print "\t<li>「くの字点」は「#{KU}#{NOJI}」で、「濁点付きくの字点」は「#{KU}#{DAKUTEN}#{NOJI}」で表しました。</li>\r\n"
      else
        @out.print "\t<li>「くの字点」は「#{KU}#{NOJI}」で表しました。</li>\r\n"
      end
    elsif @chuuki_table[:dakutenkunoji]
      @out.print "\t<li>「濁点付きくの字点」は「#{KU}#{DAKUTEN}#{NOJI}」で表しました。</li>\r\n"
    end
    if @chuuki_table[:newjis] && !Aozora2Html::Tag::EmbedGaiji.use_jisx0213
      @out.print "\t<li>「くの字点」をのぞくJIS X 0213にある文字は、画像化して埋め込みました。</li>\r\n"
    end
    if @chuuki_table[:accent] && !Aozora2Html::Tag::Accent.use_jisx0213
      @out.print "\t<li>アクセント符号付きラテン文字は、画像化して埋め込みました。</li>\r\n"
    end
    if @images[0]
      @out.print "\t<li>この作品には、JIS X 0213にない、以下の文字が用いられています。（数字は、底本中の出現「ページ-行」数。）これらの文字は本文内では「※［＃…］」の形で示しました。</li>\r\n</ul>\r\n<br />\r\n\t\t<table class=\"gaiji_list\">\r\n"
      @images.each{|cell|
       k,*v = cell
       @out.print "			<tr>
				<td>
				#{k}
				</td>
				<td>&nbsp;&nbsp;</td>
				<td>
#{v.join("、")}				</td>
				<!--
				<td>
				　　<img src=\"../../../gaiji/others/xxxx.png\" alt=\"#{k}\" width=32 height=32 />
				</td>
				-->
			</tr>
"
      }
      @out.print "\t\t</table>\r\n"
    else
      @out.print "</ul>\r\n" # <ul>内に<li>以外のエレメントが来るのは不正なので修正
    end
    @out.print "</div>\r\n"
  end
end

if $0 == __FILE__
  # todo: 引数チェックとか
  Aozora2Html.new($*[0],$*[1]).process
end
