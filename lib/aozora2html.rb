require_relative 'aozora2html/version'
require_relative 'extensions'
require_relative 'aozora2html/error'
require_relative 'aozora2html/i18n'
require_relative 'aozora2html/midashi_counter'
require_relative 'jstream'
require_relative 'aozora2html/tag'
require_relative 'aozora2html/tag_parser'
require_relative 'aozora2html/accent_parser'
require_relative 'aozora2html/style_stack'
require_relative 'aozora2html/header'
require_relative 'aozora2html/ruby_buffer'
require_relative 'aozora2html/text_buffer'
require_relative 'aozora2html/yaml_loader'
require_relative 'aozora2html/utils'
require_relative 'aozora2html/string_refinements'

# 青空文庫形式のテキストファイルを html に整形する ruby スクリプト
# 変換器本体
class Aozora2Html
  # 全角バックスラッシュが出せないから直打ち
  KU = ['18e5'].pack('h*').force_encoding('shift_jis')
  NOJI = ['18f5'].pack('h*').force_encoding('shift_jis')
  DAKUTEN = ['18d8'].pack('h*').force_encoding('shift_jis')

  using StringRefinements

  GAIJI_MARK = '※'.to_sjis
  IGETA_MARK = '＃'.to_sjis
  RUBY_BEGIN_MARK = '《'.to_sjis
  RUBY_END_MARK = '》'.to_sjis
  PAREN_BEGIN_MARK = '（'.to_sjis
  PAREN_END_MARK = '）'.to_sjis
  SIZE_SMALL = '小'.to_sjis
  SIZE_MIDDLE = '中'.to_sjis
  SIZE_LARGE = '大'.to_sjis
  TEIHON_MARK = '底本：'.to_sjis
  COMMAND_BEGIN = '［'.to_sjis
  COMMAND_END = '］'.to_sjis
  ACCENT_BEGIN = '〔'.to_sjis
  ACCENT_END = '〕'.to_sjis
  AOZORABUNKO = '青空文庫'.to_sjis
  # PAT_EDITOR = /[校訂|編|編集|編集校訂|校訂編集]$/
  PAT_EDITOR = '(校訂|編|編集)$'.to_sjis
  PAT_HENYAKU = '編訳$'.to_sjis
  PAT_TRANSLATOR = '訳$'.to_sjis
  RUBY_PREFIX = '｜'.to_sjis
  PAT_RUBY = /#{'《.*?》'.to_sjis}/.freeze
  PAT_DIRECTION = '(右|左|上|下)に(.*)'.to_sjis
  PAT_REF = '^「.+」'.to_sjis
  CHUUKI_COMMAND = '注記付き'.to_sjis
  TCY_COMMAND = '縦中横'.to_sjis
  KEIGAKOMI_COMMAND = '罫囲み'.to_sjis
  YOKOGUMI_COMMAND = '横組み'.to_sjis
  CAPTION_COMMAND = 'キャプション'.to_sjis
  WARIGAKI_COMMAND = '割書'.to_sjis
  KAERITEN_COMMAND = '返り点'.to_sjis
  KUNTEN_OKURIGANA_COMMAND = '訓点送り仮名'.to_sjis
  MIDASHI_COMMAND = '見出し'.to_sjis
  OMIDASHI_COMMAND = '大見出し'.to_sjis
  NAKAMIDASHI_COMMAND = '中見出し'.to_sjis
  KOMIDASHI_COMMAND = '小見出し'.to_sjis
  DOGYO_OMIDASHI_COMMAND = '同行大見出し'.to_sjis
  DOGYO_NAKAMIDASHI_COMMAND = '同行中見出し'.to_sjis
  DOGYO_KOMIDASHI_COMMAND = '同行小見出し'.to_sjis
  MADO_OMIDASHI_COMMAND = '窓大見出し'.to_sjis
  MADO_NAKAMIDASHI_COMMAND = '窓中見出し'.to_sjis
  MADO_KOMIDASHI_COMMAND = '窓小見出し'.to_sjis
  LEFT_MARK = '左'.to_sjis
  UNDER_MARK = '下'.to_sjis
  OVER_MARK = '上'.to_sjis
  MAIN_MARK = '本文'.to_sjis
  END_MARK = '終わり'.to_sjis
  TEN_MARK = '点'.to_sjis
  SEN_MARK = '線'.to_sjis
  OPEN_MARK = 'ここから'.to_sjis
  CLOSE_MARK = 'ここで'.to_sjis
  MADE_MARK = 'まで'.to_sjis
  DOGYO_MARK = '同行'.to_sjis
  MADO_MARK = '窓'.to_sjis
  JIAGE_COMMAND = '字上げ'.to_sjis
  JISAGE_COMMAND = '字下げ'.to_sjis
  PHOTO_COMMAND = '写真'.to_sjis
  ORIKAESHI_COMMAND = '折り返して'.to_sjis
  ONELINE_COMMAND = 'この行'.to_sjis
  NON_0213_GAIJI = '非0213外字'.to_sjis
  WARICHU_COMMAND = '割り注'.to_sjis
  TENTSUKI_COMMAND = '天付き'.to_sjis
  PAT_REST_NOTES = '(左|下)に「(.*)」の(ルビ|注記|傍記)'.to_sjis
  PAT_KUTEN = /#{'「※」[は|の]'.to_sjis}/.freeze
  PAT_KUTEN_DUAL = '※.*※'.to_sjis
  PAT_GAIJI = '(?:＃)(.*)(?:、)(.*)'.to_sjis
  PAT_KAERITEN = '^([一二三四五六七八九十レ上中下甲乙丙丁天地人]+)$'.to_sjis
  PAT_OKURIGANA = '^（(.+)）$'.to_sjis
  PAT_REMOVE_OKURIGANA = /#{'[（）]'.to_sjis}/.freeze
  PAT_CHITSUKI = /#{'(地付き|字上げ)(終わり)*$'.to_sjis}/.freeze
  PAT_ORIKAESHI_JISAGE = '折り返して(\\d*)字下げ'.to_sjis
  PAT_ORIKAESHI_JISAGE2 = '(\\d*)字下げ、折り返して(\\d*)字下げ'.to_sjis
  PAT_JI_LEN = '([0-9]+)字'.to_sjis
  PAT_INLINE_RUBY = '「(.*)」の注記付き'.to_sjis
  PAT_IMAGE = '(.*)（(fig.+\\.png)(、横([0-9]+)×縦([0-9]+))*）入る'.to_sjis
  PAT_FRONTREF = '「([^「」]*(?:「.+」)*[^「」]*)」[にはの](「.+」の)*(.+)'.to_sjis
  PAT_RUBY_DIR = '(左|下)に「([^」]*)」の(ルビ|注記)'.to_sjis
  PAT_CHUUKI = /#{'「(.+?)」の注記'.to_sjis}/.freeze
  PAT_BOUKI = /#{'「(.)」の傍記'.to_sjis}/.freeze
  PAT_CHARSIZE = /#{'(.*)段階(..)な文字'.to_sjis}/.freeze

  REGEX_HIRAGANA = Regexp.new('[ぁ-んゝゞ]'.to_sjis)
  REGEX_KATAKANA = Regexp.new('[ァ-ンーヽヾヴ]'.to_sjis)
  REGEX_ZENKAKU = Regexp.new('[０-９Ａ-Ｚａ-ｚΑ-Ωα-ωА-Яа-я−＆’，．]'.to_sjis)
  REGEX_HANKAKU = Regexp.new("[A-Za-z0-9#\\-\\&'\\,]".to_sjis)
  REGEX_KANJI = Regexp.new('[亜-熙々※仝〆〇ヶ]'.to_sjis)

  KANJI_NUMS = '〇一二三四五六七八九'.to_sjis
  KANJI_TEN = '十'.to_sjis
  ZENKAKU_NUMS = '０１２３４５６７８９'.to_sjis

  DYNAMIC_CONTENTS = "<div id=\"card\">\r\n<hr />\r\n<br />\r\n<a href=\"JavaScript:goLibCard();\" id=\"goAZLibCard\">●図書カード</a><script type=\"text/javascript\" src=\"../../contents.js\"></script>\r\n<script type=\"text/javascript\" src=\"../../golibcard.js\"></script>\r\n</div>".to_sjis

  # KUNOJI = ["18e518f5"].pack("h*")
  # utf8 ["fecbf8fecbcb"].pack("h*")
  # DAKUTENKUNOJI = ["18e518d818f5"].pack("h*")
  # utf8 ["fecbf82e083bfecbcb"].pack("h*")

  loader = Aozora2Html::YamlLoader.new(File.dirname(__FILE__))
  ACCENT_TABLE = loader.load('../yml/accent_table.yml')

  # [class, tag]
  COMMAND_TABLE = loader.load('../yml/command_table.yml')
  JIS2UCS = loader.load('../yml/jis2ucs.yml')

  INDENT_TYPE = {
    jisage: '字下げ'.to_sjis,
    chitsuki: '地付き'.to_sjis,
    midashi: '見出し'.to_sjis,
    jizume: '字詰め'.to_sjis,
    yokogumi: '横組み'.to_sjis,
    keigakomi: '罫囲み'.to_sjis,
    caption: 'キャプション'.to_sjis,
    futoji: '太字'.to_sjis,
    shatai: '斜体'.to_sjis,
    dai: '大きな文字'.to_sjis,
    sho: '小さな文字'.to_sjis
  }.freeze

  DAKUTEN_KATAKANA_TABLE = {
    '2' => 'ワ゛'.to_sjis,
    '3' => 'ヰ゛'.to_sjis,
    '4' => 'ヱ゛'.to_sjis,
    '5' => 'ヲ゛'.to_sjis
  }.freeze

  def initialize(input, output, gaiji_dir: nil, css_files: nil, use_jisx0213: nil, use_unicode: nil)
    @stream = if input.respond_to?(:read) ## readable IO?
                Jstream.new(input)
              else
                Jstream.new(File.open(input, 'rb:Shift_JIS'))
              end
    @out = if output.respond_to?(:print) ## writable IO?
             output
           else
             File.open(output, 'wb')
           end
    @gaiji_dir = gaiji_dir || '../../../gaiji/'
    @css_files = css_files || ['../../aozora.css']

    @use_jisx0213 = use_jisx0213
    @use_unicode = use_unicode

    @buffer = TextBuffer.new
    @ruby_buf = RubyBuffer.new
    @section = :head ## 現在処理中のセクション(:head,:head_end,:chuuki,:chuuki_in,:body,:tail)
    @header = Aozora2Html::Header.new(css_files: @css_files) ## ヘッダ行の配列
    @style_stack = StyleStack.new ## スタイルのスタック
    @chuuki_table = {} ## 最後にどの注記を出すかを保持しておく
    @images = [] ## 使用した外字の画像保持用
    @indent_stack = [] ## 基本はシンボルだが、ぶらさげのときはdivタグの文字列が入る
    @tag_stack = []
    @midashi_counter = MidashiCounter.new(0) ## 見出しのカウンタ、見出しの種類によって増分が異なる
    @terprip = true  ## 改行制御用 (terpriはLisp由来?)
    @endchar = :eof  ## 解析終了文字、AccentParserやTagParserでは異なる
    @noprint = nil ## 行末を読み込んだとき、何も出力しないかどうかのフラグ
  end

  def line_number
    @stream.line
  end

  def block_allowed_context?
    # inline_tagが開いていないかチェックすれば十分
    @style_stack.empty?
  end

  # parseする
  #
  # 終了時（終端まで来た場合）にはthrow :terminateで脱出する
  #
  def process
    catch(:terminate) do
      parse
    rescue Aozora2Html::Error => e
      puts e.message(line_number)
      if e.is_a?(Aozora2Html::Error)
        raise Aozora2Html::FatalError
      end
    end
    tail_output # final call
    finalize
    close
  rescue StandardError => e
    puts "ERROR: line: #{line_number}"
    raise e
  end

  def new_midashi_id(size)
    @midashi_counter.generate_id(size)
  end

  def kuten2png(substring)
    desc = substring.gsub(PAT_KUTEN, '')
    matched = desc.match(/[12]-\d{1,2}-\d{1,2}/)
    if matched && !desc.match?(NON_0213_GAIJI) && !desc.match?(PAT_KUTEN_DUAL)
      @chuuki_table[:newjis] = true
      codes = matched[0].split('-')
      folder = sprintf('%1d-%02d', codes[0], codes[1])
      code = sprintf('%1d-%02d-%02d', *codes)
      Aozora2Html::Tag::EmbedGaiji.new(self, folder, code, desc.gsub!(IGETA_MARK, ''), gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213, use_unicode: @use_unicode)
    else
      substring
    end
  end

  # コマンド文字列からモードのシンボルを取り出す
  #
  # @return [Symbol]
  #
  def detect_command_mode(command)
    if command.match?(INDENT_TYPE[:chitsuki] + END_MARK) || command.match?(JIAGE_COMMAND + END_MARK)
      return :chitsuki
    end

    INDENT_TYPE.each_key do |key|
      if command.match?(INDENT_TYPE[key])
        return key
      end
    end
    nil
  end

  private

  # 一文字読み込む
  def read_char
    @stream.read_char
  end

  # 一行読み込む
  def read_line
    @stream.read_line
  end

  def read_accent
    Aozora2Html::AccentParser.new(@stream, ACCENT_END, @chuuki_table, @images, gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213).process
  end

  def read_to_nest(endchar)
    Aozora2Html::TagParser.new(@stream, endchar, @chuuki_table, @images, gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213, use_unicode: @use_unicode).process
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
    return unless @indent_stack.last

    if check_close_match(type)
      # ok, nested multiline tags, go ahead
    else
      # not nested, please close
      @indent_stack.pop
      tag = @tag_stack.pop
      if tag
        push_chars(tag)
      end
    end
  end

  # 本文が終わってよいかチェックし、終わっていなければ例外をあげる
  def ensure_close
    n = @indent_stack.last
    return unless n

    raise Aozora2Html::Error, I18n.t(:terminate_in_style, convert_indent_type(n))
  end

  def explicit_close(type)
    n = check_close_match(type)
    if n
      raise Aozora2Html::Error, I18n.t(:invalid_closing, n, n)
    end

    tag = @tag_stack.pop
    return unless tag

    push_chars(tag)
  end

  # main loop
  def parse
    loop do
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
        raise Aozora2Html::Error, 'encount undefined condition'
      end
    end
  end

  def judge_chuuki
    # 注記が入るかどうかチェック
    i = 0
    loop do
      case @stream.peek_char(i)
      when '-'
        i += 1
      when "\r\n"
        @section = if i == 0
                     :body
                   else
                     :chuuki
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
    if string == '' # 空行がくれば、そこでヘッダー終了とみなす
      @section = :head_end
      @out.print @header.to_html
    else
      string.gsub!(RUBY_PREFIX, '')
      string.gsub!(PAT_RUBY, '')
      @header.push(string)
    end
  end

  def parse_chuuki
    string = read_line
    return unless string.match?(/^-+$/)

    case @section
    when :chuuki
      @section = :chuuki_in
    when :chuuki_in
      @section = :body
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
        Utils.illegal_char_check(char, line_number)
      end
      push_chars(escape_special_chars(char))
    end
  end

  # 本文が終了したかどうかチェックする
  #
  #
  def ending_check
    # `底本：`でフッタ(:tail)に遷移
    return unless @stream.peek_char(0) == TEIHON_MARK[1] && @stream.peek_char(1) == TEIHON_MARK[2]

    @section = :tail
    ensure_close
    @out.print "</div>\r\n<div class=\"bibliographical_information\">\r\n<hr />\r\n<br />\r\n"
  end

  def push_chars(obj)
    case obj
    when Array
      obj.each do |x|
        push_chars(x)
      end
    when String
      obj.each_char do |x|
        push_char(x)
      end
    else
      push_char(obj)
    end
  end

  def push_char(char)
    @ruby_buf.push_char(char, @buffer)
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
    @buffer = TextBuffer.new
    tail = []

    indent_type = buf.blank_type
    terprip = buf.terpri? && @terprip
    @terprip = true

    if @indent_stack.last.is_a?(String) && !indent_type
      @out.print @indent_stack.last
    end

    buf.each do |s|
      if s.is_a?(Aozora2Html::Tag::OnelineIndent)
        tail.unshift(s.close_tag)
      elsif s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) && !s.escaped?
        # 消してあった※を復活させて
        @out.print GAIJI_MARK
      end
      @out.print s.to_s
    end

    # 最後はCRLFを出力する
    if @indent_stack.last.is_a?(String)
      # ぶら下げindent
      # tail always active
      @out.print tail.map(&:to_s).join
      if indent_type == :inline
        @out.print "\r\n"
      elsif indent_type && terprip
        @out.print "<br />\r\n"
      else
        @out.print "</div>\r\n"
      end
    elsif tail.empty? && terprip
      @out.print "<br />\r\n"
    else
      @out.print tail.map(&:to_s).join
      @out.print "\r\n"
    end
  end

  # 前方参照の発見 Ruby,style重ねがけ等々のため、要素の配列で返す
  #
  # 前方参照は`○○［＃「○○」に傍点］`、`吹喋［＃「喋」に「ママ」の注記］`といった表記
  #
  # @return [TextBuffer|false]
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
    case last_string
    when String
      if last_string == ''
        searching_buf.pop
        search_front_reference(string)
      elsif last_string.match?(Regexp.new("#{Regexp.quote(string)}$"))
        # 完全一致
        # start = match.begin(0)
        # tail = match.end(0)
        # last_string[start,tail-start] = ""
        searching_buf.pop
        searching_buf.push(last_string.sub(Regexp.new("#{Regexp.quote(string)}$"), ''))
        TextBuffer.new([string])
      elsif string.match?(Regexp.new("#{Regexp.quote(last_string)}$"))
        # 部分一致
        tmp = searching_buf.pop
        found = search_front_reference(string.sub(Regexp.new("#{Regexp.quote(last_string)}$"), ''))
        if found
          found.push(tmp)
          found
        else
          searching_buf.push(tmp)
          false
        end
      end
    when Aozora2Html::Tag::ReferenceMentioned
      inner = last_string.target_string
      if inner == string
        # 完全一致
        searching_buf.pop
        TextBuffer.new([last_string])
      elsif string.match?(Regexp.new("#{Regexp.quote(inner)}$"))
        # 部分一致
        tmp = searching_buf.pop
        found = search_front_reference(string.sub(Regexp.new("#{Regexp.quote(inner)}$"), ''))
        if found
          found.push(tmp)
          found
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
        @ruby_buf.push(elt)
      elsif @buffer.last.is_a?(String)
        if elt.is_a?(String)
          @buffer.last.concat(elt)
        else
          @buffer.push(elt)
        end
      else # rubocop:disable Lint/DuplicateBranch
        @ruby_buf.push(elt)
      end
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
    if @stream.peek_char(0) != COMMAND_BEGIN
      return GAIJI_MARK
    end

    # 「［」を読み捨てる
    _ = read_char
    # embed?
    command, _raw = read_to_nest(COMMAND_END)
    try_emb = kuten2png(command)
    if try_emb != command
      return try_emb
    end

    matched = command.match(/U\+([0-9A-F]{4,5})/)
    if matched && (Aozora2Html::Tag::EmbedGaiji.use_unicode || @use_unicode)
      unicode_num = matched[1]
      Aozora2Html::Tag::EmbedGaiji.new(self, nil, nil, command, unicode_num, gaiji_dir: @gaiji_dir, use_jisx0213: @use_jisx0213, use_unicode: @use_unicode)
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
    command, raw = read_to_nest(COMMAND_END)
    # 適用順序はこれで大丈夫か？　誤爆怖いよ誤爆
    if command.match?(ORIKAESHI_COMMAND)
      apply_burasage(command)

    elsif command.start_with?(OPEN_MARK)
      exec_block_start_command(command)
    elsif command.start_with?(CLOSE_MARK)
      exec_block_end_command(command)

    elsif command.match?(WARICHU_COMMAND)
      apply_warichu(command)
    elsif command.match?(JISAGE_COMMAND)
      apply_jisage(command)
    elsif command.match?(/fig(\d)+_(\d)+\.png/)
      exec_img_command(command, raw)
    # avoid to try complex ruby -- escape to notes
    elsif command.match?(PAT_REST_NOTES)
      apply_rest_notes(command)
    elsif command.end_with?(END_MARK)
      exec_inline_end_command(command)
      nil
    elsif command.match?(PAT_REF)
      exec_frontref_command(command)
    elsif command.match?(/1-7-8[2345]/)
      apply_dakuten_katakana(command)
    elsif command.match?(PAT_KAERITEN)
      Aozora2Html::Tag::Kaeriten.new(self, command)
    elsif command.match?(PAT_OKURIGANA)
      Aozora2Html::Tag::Okurigana.new(self, command.gsub!(PAT_REMOVE_OKURIGANA, ''))
    elsif command.match?(PAT_CHITSUKI)
      apply_chitsuki(command)
    elsif exec_inline_start_command(command)
      nil
    else # rubocop:disable Lint/DuplicateBranch
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
    if command.match?(TENTSUKI_COMMAND)
      width = command.match(PAT_ORIKAESHI_JISAGE)[1]
      tag = "<div class=\"burasage\" style=\"margin-left: #{width}em; text-indent: -#{width}em;\">"
    else
      matched = command.match(PAT_ORIKAESHI_JISAGE2)
      left, indent = matched.to_a[1, 2]
      left = left.to_i - indent.to_i
      tag = "<div class=\"burasage\" style=\"margin-left: #{indent}em; text-indent: #{left}em;\">"
    end
    @indent_stack.push(tag)
    @tag_stack.push('') # dummy
    nil
  end

  def jisage_width(command)
    Utils.convert_japanese_number(command).match(/(\d*)(?:#{JISAGE_COMMAND})/o)[1]
  end

  def apply_jisage(command)
    if command.match?(MADE_MARK) || command.match?(END_MARK)
      # 字下げ終わり
      explicit_close(:jisage)
      @indent_stack.pop
      nil
    elsif command.match?(ONELINE_COMMAND)
      # 1行だけ
      @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
      nil
    elsif (@buffer.length == 0) && (@stream.peek_char(0) == "\r\n")
      # commandのみ
      @terprip = false
      implicit_close(:jisage)
      # adhook hack
      @noprint = false
      @indent_stack.push(:jisage)
      Aozora2Html::Tag::MultilineJisage.new(self, jisage_width(command))
    else # rubocop:disable Lint/DuplicateBranch
      @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
      nil
    end
  end

  def apply_warichu(command)
    if command.match?(END_MARK)
      if @stream.peek_char(0) != PAREN_END_MARK
        push_char(PAREN_END_MARK)
      end
      push_char('</span>')
    else
      check = @ruby_buf.last

      # NOTE: Do not remove duplicates!
      if check.is_a?(String) && check.end_with?(PAREN_BEGIN_MARK)
        push_char('<span class="warichu">')
      else
        push_char('<span class="warichu">')
        push_char(PAREN_BEGIN_MARK)
      end
    end
    nil
  end

  def chitsuki_length(command)
    command = Utils.convert_japanese_number(command)
    matched = command.match(PAT_JI_LEN)
    if matched
      matched[1]
    else
      '0'
    end
  end

  def apply_chitsuki(string, multiline: false)
    if string.match?(CLOSE_MARK + INDENT_TYPE[:chitsuki] + END_MARK) ||
       string.match?(CLOSE_MARK + JIAGE_COMMAND + END_MARK)
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

  def apply_midashi(command)
    @indent_stack.push(:midashi)
    if command.match?(DOGYO_MARK)
      midashi_type = :dogyo
    elsif command.match?(MADO_MARK)
      midashi_type = :mado
    else
      midashi_type = :normal
      @terprip = false
    end
    Aozora2Html::Tag::MultilineMidashi.new(self, command, midashi_type)
  end

  def apply_yokogumi(_command)
    @indent_stack.push(:yokogumi)
    Aozora2Html::Tag::MultilineYokogumi.new(self)
  end

  def apply_keigakomi(_command)
    @indent_stack.push(:keigakomi)
    Aozora2Html::Tag::Keigakomi.new(self)
  end

  def apply_caption(_command)
    @indent_stack.push(:caption)
    Aozora2Html::Tag::MultilineCaption.new(self)
  end

  def apply_jizume(command)
    w = Utils.convert_japanese_number(command).match(/(\d*)(?:#{INDENT_TYPE[:jizume]})/)[1]
    @indent_stack.push(:jizume)
    Aozora2Html::Tag::Jizume.new(self, w)
  end

  def push_block_tag(tag, closing)
    push_char(tag)
    closing.concat(tag.close_tag)
  end

  def detect_style_size(style)
    if style.match?('小'.to_sjis)
      :sho
    else
      :dai
    end
  end

  def exec_inline_start_command(command)
    case command
    when CHUUKI_COMMAND
      @style_stack.push([command, '</ruby>'])
      push_char('<ruby><rb>')
    when TCY_COMMAND
      @style_stack.push([command, '</span>'])
      push_char('<span dir="ltr">')
    when KEIGAKOMI_COMMAND
      @style_stack.push([command, '</span>'])
      push_char('<span class="keigakomi">')
    when YOKOGUMI_COMMAND
      @style_stack.push([command, '</span>'])
      push_char('<span class="yokogumi">')
    when CAPTION_COMMAND
      @style_stack.push([command, '</span>'])
      push_char('<span class="caption">')
    when WARIGAKI_COMMAND
      @style_stack.push([command, '</span>'])
      push_char('<span class="warigaki">')
    when OMIDASHI_COMMAND
      @style_stack.push([command, '</a></h3>'])
      @terprip = false
      push_char("<h3 class=\"o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(100)}\">")
    when NAKAMIDASHI_COMMAND
      @style_stack.push([command, '</a></h4>'])
      @terprip = false
      push_char("<h4 class=\"naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(10)}\">")
    when KOMIDASHI_COMMAND
      @style_stack.push([command, '</a></h5>'])
      @terprip = false
      push_char("<h5 class=\"ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(1)}\">")
    when DOGYO_OMIDASHI_COMMAND
      @style_stack.push([command, '</a></h3>'])
      push_char("<h3 class=\"dogyo-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(100)}\">")
    when DOGYO_NAKAMIDASHI_COMMAND
      @style_stack.push([command, '</a></h4>'])
      push_char("<h4 class=\"dogyo-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(10)}\">")
    when DOGYO_KOMIDASHI_COMMAND
      @style_stack.push([command, '</a></h5>'])
      push_char("<h5 class=\"dogyo-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(1)}\">")
    when MADO_OMIDASHI_COMMAND
      @style_stack.push([command, '</a></h3>'])
      push_char("<h3 class=\"mado-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(100)}\">")
    when MADO_NAKAMIDASHI_COMMAND
      @style_stack.push([command, '</a></h4>'])
      push_char("<h4 class=\"mado-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(10)}\">")
    when MADO_KOMIDASHI_COMMAND
      @style_stack.push([command, '</a></h5>'])
      push_char("<h5 class=\"mado-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{@midashi_counter.generate_id(1)}\">")
    when PAT_CHARSIZE
      @style_stack.push([command, '</span>'])
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      times = Utils.convert_japanese_number(nest).to_i
      daisho = detect_style_size(style)
      html_class = daisho.to_s + times.to_s
      size = Utils.create_font_size(times, daisho)
      push_char("<span class=\"#{html_class}\" style=\"font-size: #{size};\">")
    else
      ## Decoration ##
      key = command
      filter = ->(x) { x }
      if command.match?(PAT_DIRECTION)
        _whole, dir, com = command.match(PAT_DIRECTION).to_a
        # renew command
        key = com
        if command.match?(TEN_MARK)
          case dir
          when LEFT_MARK, UNDER_MARK
            filter = ->(x) { "#{x}_after" }
          end
        elsif command.match?(SEN_MARK)
          case dir
          when LEFT_MARK, OVER_MARK
            filter = ->(x) { x.sub('under', 'over') }
          end
        end
      end

      found = COMMAND_TABLE[key]
      # found = [class, tag]
      if found
        @style_stack.push([command, "</#{found[1]}>"])
        push_char("<#{found[1]} class=\"#{filter.call(found[0])}\">")
      else
        if $DEBUG
          puts I18n.t(:warn_undefined_command, line_number, key)
        end
        nil
      end
    end
  end

  def exec_inline_end_command(command)
    encount = command.sub(END_MARK, '')
    if encount == MAIN_MARK
      # force to finish main_text
      @section = :tail
      ensure_close
      @noprint = true
      @out.print "</div>\r\n<div class=\"after_text\">\r\n<hr />\r\n"
    elsif encount.match?(CHUUKI_COMMAND) && (@style_stack.last_command == CHUUKI_COMMAND)
      # special inline ruby
      @style_stack.pop
      _whole, ruby = encount.match(PAT_INLINE_RUBY).to_a
      push_char('</rb><rp>' + PAREN_BEGIN_MARK + '</rp><rt>' + ruby + '</rt><rp>' + PAREN_END_MARK + '</rp></ruby>') # rubocop:disable Style/StringConcatenation
    elsif @style_stack.last_command.match?(encount)
      push_char(@style_stack.pop[1])
    else
      raise Aozora2Html::Error, I18n.t(:invalid_nesting, encount, @style_stack.last_command)
    end
  end

  def exec_block_start_command(command)
    original_command = command.dup
    command.sub!(/^#{OPEN_MARK}/o, '')
    match_buf = +''
    if command.match?(INDENT_TYPE[:jisage])
      push_block_tag(apply_jisage(command), match_buf)
    elsif command.match?(/(#{INDENT_TYPE[:chitsuki]}|#{JIAGE_COMMAND})$/)
      push_block_tag(apply_chitsuki(command, multiline: true), match_buf)
    end

    if command.match?(INDENT_TYPE[:midashi])
      push_block_tag(apply_midashi(command), match_buf)
    end

    if command.match?(INDENT_TYPE[:jizume])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(apply_jizume(command), match_buf)
    end

    if command.match?(INDENT_TYPE[:yokogumi])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(apply_yokogumi(command), match_buf)
    end

    if command.match?(INDENT_TYPE[:keigakomi])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(apply_keigakomi(command), match_buf)
    end

    if command.match?(INDENT_TYPE[:caption])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(apply_caption(command), match_buf)
    end

    if command.match?(INDENT_TYPE[:futoji])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, 'futoji'), match_buf)
      @indent_stack.push(:futoji)
    end
    if command.match?(INDENT_TYPE[:shatai])
      if match_buf != ''
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, 'shatai'), match_buf)
      @indent_stack.push(:shatai)
    end

    if command.match?(PAT_CHARSIZE)
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      if match_buf != ''
        @indent_stack.pop
      end
      daisho = detect_style_size(style)
      push_block_tag(Aozora2Html::Tag::FontSize.new(self,
                                                    Utils.convert_japanese_number(nest).to_i,
                                                    daisho),
                     match_buf)
      @indent_stack.push(daisho)
    end

    if match_buf == ''
      apply_rest_notes(original_command)
    else
      @tag_stack.push(match_buf)
      nil
    end
  end

  def exec_block_end_command(command)
    original_command = command.dup
    command.sub!(/^#{CLOSE_MARK}/o, '')
    matched = false
    mode = detect_command_mode(command)
    if mode
      explicit_close(mode)
      matched = @indent_stack.pop
    end

    if matched
      unless matched.is_a?(String)
        @terprip = false
      end
      nil
    else
      apply_rest_notes(original_command)
    end
  end

  def exec_img_command(command, raw)
    matched = raw.match(PAT_IMAGE)
    if matched
      _whole, alt, src, _wh, width, height = matched.to_a
      css_class = if alt.match?(PHOTO_COMMAND)
                    'photo'
                  else
                    'illustration'
                  end
      Aozora2Html::Tag::Img.new(self, src, css_class, alt, width, height)
    else
      apply_rest_notes(command)
    end
  end

  def exec_frontref_command(command)
    _whole, reference, spec1, spec2 = command.match(PAT_FRONTREF).to_a
    spec = if spec1
             spec1 + spec2
           else
             spec2
           end
    if reference
      found = search_front_reference(reference)
      if found
        tmp = exec_style(found, spec)
        return tmp if tmp

        recovery_front_reference(found)
      end
    end
    # comment out?
    apply_rest_notes(command)
  end

  # 傍記を並べる用
  #
  def multiply(bouki, times)
    sep = '&nbsp;'
    ([bouki] * times).join(sep)
  end

  # rubyタグの再生成(本体はrearrange_ruby)
  #
  # complex ruby wrap up utilities -- don't erase! we will use soon ...
  #
  def rearrange_ruby_tag(targets, upper_ruby, under_ruby)
    Aozora2Html::Tag::Ruby.rearrange_ruby(self, targets, upper_ruby, under_ruby)
  end

  def exec_style(targets, command)
    try_kuten = kuten2png(command)
    if try_kuten != command
      try_kuten
    elsif command.match?(TCY_COMMAND)
      Aozora2Html::Tag::Dir.new(self, targets)
    elsif command.match?(YOKOGUMI_COMMAND)
      Aozora2Html::Tag::InlineYokogumi.new(self, targets)
    elsif command.match?(KEIGAKOMI_COMMAND)
      Aozora2Html::Tag::InlineKeigakomi.new(self, targets)
    elsif command.match?(CAPTION_COMMAND)
      Aozora2Html::Tag::InlineCaption.new(self, targets)
    elsif command.match?(KAERITEN_COMMAND)
      Aozora2Html::Tag::Kaeriten.new(self, targets)
    elsif command.match?(KUNTEN_OKURIGANA_COMMAND)
      Aozora2Html::Tag::Okurigana.new(self, targets)
    elsif command.match?(MIDASHI_COMMAND)
      midashi_type = :normal
      if command.match?(DOGYO_MARK)
        midashi_type = :dogyo
      elsif command.match?(MADO_MARK)
        midashi_type = :mado
      else
        @terprip = false
      end
      Aozora2Html::Tag::Midashi.new(self, targets, command, midashi_type)
    elsif command.match?(PAT_CHARSIZE)
      _whole, nest, style = command.match(PAT_CHARSIZE).to_a
      Aozora2Html::Tag::InlineFontSize.new(self, targets,
                                           Utils.convert_japanese_number(nest).to_i,
                                           detect_style_size(style))
    elsif command.match?(PAT_RUBY_DIR)
      _whole, _dir, under = command.match(PAT_RUBY_DIR).to_a
      if (targets.length == 1) && targets[0].is_a?(Aozora2Html::Tag::Ruby)
        tag = targets[0]
        raise Aozora2Html::Error, I18n.t(:dont_allow_triple_ruby) unless tag.under_ruby == ''

        tag.under_ruby = under
        tag
      else
        rearrange_ruby_tag(targets, '', under)
      end
    elsif command.match?(PAT_CHUUKI)
      rearrange_ruby_tag(targets, PAT_CHUUKI.match(command).to_a[1], '')
    elsif command.match?(PAT_BOUKI)
      rearrange_ruby_tag(targets, multiply(PAT_BOUKI.match(command).to_a[1], targets.to_s.length), '')
    else
      ## direction fix! ##
      filter = ->(x) { x }
      if command.match?(PAT_DIRECTION)
        _whole, dir, com = command.match(PAT_DIRECTION).to_a
        # renew command
        command = com
        if command.match?(TEN_MARK)
          case dir
          when LEFT_MARK, UNDER_MARK
            filter = ->(x) { "#{x}_after" }
          end
        elsif command.match?(SEN_MARK)
          case dir
          when LEFT_MARK, OVER_MARK
            filter = ->(x) { x.sub('under', 'over') }
          end
        end
      end

      found = COMMAND_TABLE[command]
      # found = [class, tag]
      if found
        Aozora2Html::Tag::Decorate.new(self, targets, filter.call(found[0]), found[1])
      end
    end
  end

  def apply_dakuten_katakana(command)
    n = command.match(/1-7-8([2345])/).to_a[1]
    frontref = DAKUTEN_KATAKANA_TABLE[n]
    found = search_front_reference(frontref)
    if found
      Aozora2Html::Tag::DakutenKatakana.new(self, n, found.join, gaiji_dir: @gaiji_dir)
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
      return RUBY_BEGIN_MARK + RUBY_END_MARK
    end

    @buffer.concat(@ruby_buf.create_ruby(self, ruby))

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
        Utils.illegal_char_check(char, line_number)
      end
      push_chars(escape_special_chars(char))
    end
  end

  # general_outputのフッタ版
  def tail_output
    @ruby_buf.dump_into(@buffer)
    string = @buffer.join
    @buffer = TextBuffer.new
    string.gsub!('info@aozora.gr.jp', '<a href="mailto: info@aozora.gr.jp">info@aozora.gr.jp</a>')
    string.gsub!(AOZORABUNKO + PAREN_BEGIN_MARK + 'http://www.aozora.gr.jp/' + PAREN_END_MARK) { "<a href=\"http://www.aozora.gr.jp/\">#{$&}</a>" } # rubocop:disable Style/StringConcatenation
    if string.match?(%r{(<br />$|</p>$|</h\d>$|<div.*>$|</div>$|^<[^>]*>$)})
      @out.print string, "\r\n"
    else
      @out.print string, "<br />\r\n"
    end
  end

  # `●表記について`で使用した注記等を出力する
  def hyoki
    # <br /> times fix
    @out.print "<br />\r\n</div>\r\n<div class=\"notation_notes\">\r\n<hr />\r\n<br />\r\n●表記について<br />\r\n<ul>\r\n".to_sjis
    @out.print "\t<li>このファイルは W3C 勧告 XHTML1.1 にそった形式で作成されています。</li>\r\n".to_sjis
    if @chuuki_table[:chuki]
      @out.print "\t<li>［＃…］は、入力者による注を表す記号です。</li>\r\n".to_sjis
    end
    if @chuuki_table[:kunoji]
      if @chuuki_table[:dakutenkunoji]
        @out.printf("\t<li>「くの字点」は「%s」で、「濁点付きくの字点」は「%s」で表しました。</li>\r\n".to_sjis, KU + NOJI, KU + DAKUTEN + NOJI)
      else
        @out.printf("\t<li>「くの字点」は「%s」で表しました。</li>\r\n".to_sjis, KU + NOJI)
      end
    elsif @chuuki_table[:dakutenkunoji]
      @out.printf("\t<li>「濁点付きくの字点」は「%s」で表しました。</li>\r\n".to_sjis, KU + DAKUTEN + NOJI)
    end
    if @chuuki_table[:newjis] && !(Aozora2Html::Tag::EmbedGaiji.use_jisx0213 || @use_jisx0213)
      @out.print "\t<li>「くの字点」をのぞくJIS X 0213にある文字は、画像化して埋め込みました。</li>\r\n".to_sjis
    end
    if @chuuki_table[:accent] && !(Aozora2Html::Tag::Accent.use_jisx0213 || @use_jisx0213)
      @out.print "\t<li>アクセント符号付きラテン文字は、画像化して埋め込みました。</li>\r\n".to_sjis
    end
    if @images[0]
      @out.print "\t<li>この作品には、JIS X 0213にない、以下の文字が用いられています。（数字は、底本中の出現「ページ-行」数。）これらの文字は本文内では「※［＃…］」の形で示しました。</li>\r\n</ul>\r\n<br />\r\n\t\t<table class=\"gaiji_list\">\r\n".to_sjis
      @images.each do |cell|
        k, *v = cell
        vs = v.join('、'.to_sjis)
        @out.print "\t\t\t<tr>\r\n\t\t\t\t<td>\r\n\t\t\t\t#{k}\r\n\t\t\t\t</td>\r\n\t\t\t\t<td>&nbsp;&nbsp;</td>\r\n\t\t\t\t<td>\r\n#{vs}\t\t\t\t</td>\r\n\t\t\t\t<!--\r\n\t\t\t\t<td>\r\n\t\t\t\t" + '　　'.to_sjis + "<img src=\"../../../gaiji/others/xxxx.png\" alt=\"#{k}\" width=32 height=32 />\r\n\t\t\t\t</td>\r\n\t\t\t\t-->\r\n\t\t\t</tr>\r\n".to_sjis
      end
      @out.print "\t\t</table>\r\n".to_sjis
    else
      @out.print "</ul>\r\n" # <ul>内に<li>以外のエレメントが来るのは不正なので修正
    end
    @out.print "</div>\r\n"
  end

  # Original Aozora2Html#push_chars does not convert "'" into '&#39;'; it's old behaivor of CGI.escapeHTML().
  def escape_special_chars(char)
    if char.is_a?(String)
      char.gsub(/[&"<>]/, { '&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;' })
    else
      char
    end
  end
end
