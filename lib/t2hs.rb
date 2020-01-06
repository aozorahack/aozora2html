# -*- coding:shift_jis -*-
# �󕶌Ɍ`���̃e�L�X�g�t�@�C���� html �ɐ��`���� ruby �X�N���v�g
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

# �ϊ���{��
class Aozora2Html

  # �S�p�o�b�N�X���b�V�����o���Ȃ����璼�ł�
  KU = ["18e5"].pack("h*").force_encoding("shift_jis")
  NOJI = ["18f5"].pack("h*").force_encoding("shift_jis")
  DAKUTEN = ["18d8"].pack("h*").force_encoding("shift_jis")
  GAIJI_MARK = "��"
  IGETA_MARK = "��"
  RUBY_BEGIN_MARK = "�s"
  RUBY_END_MARK = "�t"
  PAREN_BEGIN_MARK = "�i"
  PAREN_END_MARK = "�j"
  SIZE_SMALL = "��"
  SIZE_MIDDLE = "��"
  SIZE_LARGE = "��"
  TEIHON_MARK = "��{�F"
  COMMAND_BEGIN = "�m"
  COMMAND_END = "�n"
  ACCENT_BEGIN = "�k"
  ACCENT_END = "�l"
  AOZORABUNKO = "�󕶌�"
  #PAT_EDITOR = /[�Z��|��|�ҏW|�ҏW�Z��|�Z���ҏW]$/
  PAT_EDITOR = /(�Z��|��|�ҏW)$/
  PAT_HENYAKU = /�Җ�$/
  PAT_TRANSLATOR = /��$/
  RUBY_PREFIX = "�b"
  PAT_RUBY = /�s.*?�t/
  PAT_DIRECTION = /(�E|��|��|��)��(.*)/
  PAT_REF = /^�u.+�v/
  CHUUKI_COMMAND = "���L�t��"
  TCY_COMMAND = "�c����"
  KEIGAKOMI_COMMAND = "�r�͂�"
  YOKOGUMI_COMMAND = "���g��"
  CAPTION_COMMAND = "�L���v�V����"
  WARIGAKI_COMMAND = "����"
  KAERITEN_COMMAND = "�Ԃ�_"
  KUNTEN_OKURIGANA_COMMAND = "�P�_���艼��"
  MIDASHI_COMMAND = "���o��"
  OMIDASHI_COMMAND = "�匩�o��"
  NAKAMIDASHI_COMMAND = "�����o��"
  KOMIDASHI_COMMAND = "�����o��"
  DOGYO_OMIDASHI_COMMAND = "���s�匩�o��"
  DOGYO_NAKAMIDASHI_COMMAND = "���s�����o��"
  DOGYO_KOMIDASHI_COMMAND = "���s�����o��"
  MADO_OMIDASHI_COMMAND = "���匩�o��"
  MADO_NAKAMIDASHI_COMMAND = "�������o��"
  MADO_KOMIDASHI_COMMAND = "�������o��"
  LEFT_MARK = "��"
  UNDER_MARK = "��"
  OVER_MARK = "��"
  MAIN_MARK = "�{��"
  END_MARK = "�I���"
  TEN_MARK = "�_"
  SEN_MARK = "��"
  OPEN_MARK = "��������"
  CLOSE_MARK = "������"
  MADE_MARK = "�܂�"
  DOGYO_MARK = "���s"
  MADO_MARK = "��"
  JIAGE_COMMAND = "���グ"
  JISAGE_COMMAND = "������"
  PHOTO_COMMAND = "�ʐ^"
  ORIKAESHI_COMMAND = "�܂�Ԃ���"
  ONELINE_COMMAND = "���̍s"
  NON_0213_GAIJI = "��0213�O��"
  WARICHU_COMMAND = "���蒍"
  TENTSUKI_COMMAND = "�V�t��"
  PAT_REST_NOTES = /(��|��)�Ɂu(.*)�v��(���r|���L|�T�L)/
  PAT_KUTEN = /�u���v[��|��]/
  PAT_KUTEN_DUAL = /��.*��/
  PAT_GAIJI = /(?:��)(.*)(?:�A)(.*)/
  PAT_KAERITEN = /^([���O�l�ܘZ������\���㒆���b�������V�n�l]+)$/
  PAT_OKURIGANA = /^�i(.+)�j$/
  PAT_REMOVE_OKURIGANA = /[�i�j]/
  PAT_CHITSUKI = /(�n�t��|���グ)(�I���)*$/
  PAT_ORIKAESHI_JISAGE = /�܂�Ԃ���(\d*)������/
  PAT_ORIKAESHI_JISAGE2 = /(\d*)�������A�܂�Ԃ���(\d*)������/
  PAT_JI_LEN = /([0-9]+)��/
  PAT_INLINE_RUBY = "�u(.*)�v�̒��L�t��"
  PAT_IMAGE = /(.*)�i(fig.+\.png)(�A��([0-9]+)�~�c([0-9]+))*�j����/
  PAT_FRONTREF = /�u([^�u�v]*(?:�u.+�v)*[^�u�v]*)�v[�ɂ͂�](�u.+�v��)*(.+)/
  PAT_RUBY_DIR = /(��|��)�Ɂu([^�v]*)�v��(���r|���L)/
  PAT_CHUUKI = /�u(.+?)�v�̒��L/
  PAT_BOUKI = /�u(.)�v�̖T�L/
  PAT_CHARSIZE = /(.*)�i�K(..)�ȕ���/

  DYNAMIC_CONTENTS = "<div id=\"card\">\r\n<hr />\r\n<br />\r\n" +
                     "<a href=\"JavaScript:goLibCard();\" id=\"goAZLibCard\">���}���J�[�h</a>" +
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
    :jisage => "������",
    :chitsuki => "�n�t��",
    :midashi => "���o��",
    :jizume => "���l��",
    :yokogumi => "���g��",
    :keigakomi => "�r�͂�",
    :caption => "�L���v�V����",
    :futoji => "����",
    :shatai => "�Α�",
    :dai => "�傫�ȕ���",
    :sho => "�����ȕ���",
  }

  DAKUTEN_KATAKANA_TABLE = {
    "2" => "���J",
    "3" => "���J",
    "4" => "���J",
    "5" => "���J",
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
    @section = :head  ## ���ݏ������̃Z�N�V����(:head,:head_end,:chuuki,:chuuki_in,:body,:tail)
    @header = Aozora2Html::Header.new()  ## �w�b�_�s�̔z��
    @style_stack = StyleStack.new  ##�X�^�C���̃X�^�b�N
    @chuuki_table = {} ## �Ō�ɂǂ̒��L���o������ێ����Ă���
    @images = []  ## �g�p�����O���̉摜�ێ��p
    @indent_stack = [] ## ��{�̓V���{�������A�Ԃ炳���̂Ƃ���div�^�O�̕����񂪓���
    @tag_stack = []
    @midashi_id = 0  ## ���o���̃J�E���^�A���o���̎�ނɂ���đ������قȂ�
    @terprip = true  ## ���s����p (terpri��Lisp�R��?)
    @endchar = :eof  ## ��͏I�������AAccentParser��TagParser�ł͈قȂ�
    @noprint = nil  ## �s����ǂݍ��񂾂Ƃ��A�����o�͂��Ȃ����ǂ����̃t���O
  end

  def line_number
    @stream.line
  end

  def block_allowed_context?
    # inline_tag���J���Ă��Ȃ����`�F�b�N����Ώ\��
    @style_stack.empty?
  end

  # �ꕶ���ǂݍ���
  def read_char
    @stream.read_char
  end

  # �w�肳�ꂽ�I�[����(1������String��CRLF)�܂œǂݍ���
  #
  #  @param [String] endchar �I�[����
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

  # 1�s�ǂݍ���
  #
  # ���킹��@buffer���N���A����
  # @return [String] �ǂݍ��񂾕������Ԃ�
  #
  def read_line
    tmp = read_to("\r\n")
    @buffer = []
    tmp
  end

  # parse����
  #
  # �I�����i�I�[�܂ŗ����ꍇ�j�ɂ�throw :terminate�ŒE�o����
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
      ## `String#char_type`����`����Ă���̂ɒ���
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

  # �L�@�̃V���{�������當����֕ϊ�����
  # �V���{����������Ȃ���΂��̂܂ܕԂ�
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

  # �{�����I����Ă悢���`�F�b�N���A�I����Ă��Ȃ���Η�O��������
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
    # ���L�����邩�ǂ����`�F�b�N
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

  # header�͈�s���ǂ�
  def parse_header
    string = read_line
    # refine from Tomita 09/06/14
    if string == ""  # ��s������΁A�����Ńw�b�_�[�I���Ƃ݂Ȃ�
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

  # �g���ׂ��ł͂Ȃ����������邩�`�F�b�N����
  #
  # �x�����o�͂��邾���Ō��ʂɂ͉e����^���Ȃ��B�x�����镶���͈ȉ�:
  #
  # * 1�o�C�g����
  # * `��`�ł͂Ȃ�`��`
  # * JIS(JIS X 0208)�O��
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

  # �{�̉�͕�
  #
  # 1�������ǂݍ��݁Adispatch����@buffer,@ruby_buf�ւ��܂�
  # ���s�R�[�h�ɓ��������痭�ߍ��񂾂��̂�general_output����
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

  # �{�����I���������ǂ����`�F�b�N����
  #
  #
  def ending_check
    # `��{�F`�Ńt�b�^(:tail)�ɑJ��
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

  # �s�o�͎���@buffer���󂩂ǂ������ׂ�
  #
  # @buffer�̒��g�ɂ���čs���̏o�͂��قȂ邽��
  #
  # @return [true, false, :inline] �󕶎��ł͂Ȃ������񂪓����Ă����false�A1�s���L�Ȃ�:inline�A����ȊO���������Ă��Ȃ����true
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

  # �s����<br />���o�͂���ׂ����ǂ����̔��ʗp
  #
  # @return [true, false] Multiline�̒��L���������Ă��Ȃ����false�AMultiline�ł��󕶎��ł��Ȃ��v�f���܂܂�Ă����true
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

  # �ǂݍ��񂾍s�̏o�͂��s��
  #
  # parser�����s������ǂݍ��񂾂�Ă΂��B
  # �ŏI�I��@ruby_buf��@buffer�͏���������
  #
  # @return [void]
  #
  def general_output
    if @style_stack.last
      raise Aozora2Html::Error, I18n.t(:dont_crlf_in_style, @style_stack.last_command)
    end
    # buffer�ɃC���f���g�^�O����������������s���Ȃ��I
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
        # �����Ă��������𕜊�������
        @out.print GAIJI_MARK
      end
      @out.print s.to_s
    end

    # �Ō��CRLF���o�͂���
    if @indent_stack.last.is_a?(String)
      # �Ԃ牺��indent
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

  # �O���Q�Ƃ̔��� Ruby,style�d�˂������X�̂��߁A�v�f�̔z��ŕԂ�
  #
  # �O���Q�Ƃ�`�����m���u�����v�ɖT�_�n`�A`�����m���u���v�Ɂu�}�}�v�̒��L�n`�Ƃ������\�L
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
        # ���S��v
        # start = match.begin(0)
        # tail = match.end(0)
        # last_string[start,tail-start] = ""
        searching_buf.pop
        searching_buf.push(last_string.sub(Regexp.new(Regexp.quote(string)+"$"),""))
        [string]
      elsif string.match(Regexp.new(Regexp.quote(last_string)+"$"))
        # ������v
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
        # ���S��v
        searching_buf.pop
        [last_string]
      elsif string.match(Regexp.new(Regexp.quote(inner)+"$"))
        # ������v
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

  # ���������O���Q�Ƃ����ɖ߂�
  #
  # @ruby_buf�������@ruby_buf�ɁA�Ȃ����@buffer��push����
  # �o�b�t�@�̍Ō�Ɗe�v�f��������Ȃ�concat���A�ǂ��炪������łȂ���΁iconcat�ł��Ȃ��̂Łjpush����
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
    # �u���v�̎����u�m�v�łȂ���ΊO���ł͂Ȃ�
    if @stream.peek_char(0) !=  COMMAND_BEGIN
      return GAIJI_MARK
    end

    # �u�m�v��ǂݎ̂Ă�
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

  # ���L�L�@�̏ꍇ����
  def dispatch_aozora_command
    # �u�m�v�̎����u���v�łȂ���Β��L�ł͂Ȃ�
    if @stream.peek_char(0) != IGETA_MARK
      return COMMAND_BEGIN
    end

    # �u���v��ǂݎ̂Ă�
    _ = read_char
    command,raw = read_to_nest(COMMAND_END)
    # �K�p�����͂���ő��v���H�@�딚�|����딚
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
      # �������I���
      explicit_close(:jisage)
      @indent_stack.pop
      nil
    elsif command.match(ONELINE_COMMAND)
      # 1�s����
      @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
      nil
    elsif @buffer.length == 0 and @stream.peek_char(0) == "\r\n"
      # command�̂�
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
        # �����s�w��
        implicit_close(:chitsuki)
        @indent_stack.push(:chitsuki)
        Aozora2Html::Tag::MultilineChitsuki.new(self, len)
      else
        # 1�s�̂�
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
    if style.match("��")
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
      push_char("</rb><rp>�i</rp><rt>#{ruby}</rt><rp>�j</rp></ruby>")
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

  # �R�}���h�����񂩂烂�[�h�̃V���{�������o��
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

  # �T�L����ׂ�p
  #
  def multiply(bouki, times)
    sep = "&nbsp;"
    ([bouki]*times).join(sep)
  end

  # array�����r���܂�ł���΂��̃C���f�b�N�X��Ԃ�
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

  # ruby�^�O�̍Đ���(�{�̂�rearrange_ruby)
  #
  # complex ruby wrap up utilities -- don't erase! we will use soon ...
  #
  def rearrange_ruby_tag(targets, upper_ruby, under_ruby = "")
    target, upper, under = rearrange_ruby(targets, upper_ruby, under_ruby)
    Aozora2Html::Tag::Ruby.new(self, target, upper, under)
  end

  # ruby�^�O�̍Ċ��蓖��
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

  # ���̎��_�̏���
  #
  # ���̎��_�͌��󂻂̂܂܏o�͂���̂Ńt�b�^�́u�\�L�ɂ��āv�ŏo�͂��邩�ǂ����̃t���O���������s��
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

  # �b�������Ƃ��͕�����𖳎�����ruby_buf�����Ȃ��Ⴂ���Ȃ�
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

  # parse_body�̃t�b�^��
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

  # general_output�̃t�b�^��
  def tail_output
    @ruby_buf.dump_into(@buffer)
    string = @buffer.join
    @ruby_buf.clear
    @buffer = []
    string.gsub!("info@aozora.gr.jp",'<a href="mailto: info@aozora.gr.jp">info@aozora.gr.jp</a>')
    string.gsub!("�󕶌Ɂihttp://www.aozora.gr.jp/�j"){"<a href=\"http://www.aozora.gr.jp/\">#{$&}</a>"}
    if string.match(/(<br \/>$|<\/p>$|<\/h\d>$|<div.*>$|<\/div>$|^<[^>]*>$)/)
      @out.print string, "\r\n"
    else
      @out.print string, "<br />\r\n"
    end
  end

  # `���\�L�ɂ���`�Ŏg�p�������L�����o�͂���
  def hyoki
    # <br /> times fix
    @out.print "<br />\r\n</div>\r\n<div class=\"notation_notes\">\r\n<hr />\r\n<br />\r\n���\�L�ɂ���<br />\r\n<ul>\r\n"
    @out.print "\t<li>���̃t�@�C���� W3C ���� XHTML1.1 �ɂ������`���ō쐬����Ă��܂��B</li>\r\n"
    if @chuuki_table[:chuki]
      @out.print "\t<li>�m���c�n�́A���͎҂ɂ�钍��\���L���ł��B</li>\r\n"
    end
    if @chuuki_table[:kunoji]
      if @chuuki_table[:dakutenkunoji]
        @out.print "\t<li>�u���̎��_�v�́u#{KU}#{NOJI}�v�ŁA�u���_�t�����̎��_�v�́u#{KU}#{DAKUTEN}#{NOJI}�v�ŕ\���܂����B</li>\r\n"
      else
        @out.print "\t<li>�u���̎��_�v�́u#{KU}#{NOJI}�v�ŕ\���܂����B</li>\r\n"
      end
    elsif @chuuki_table[:dakutenkunoji]
      @out.print "\t<li>�u���_�t�����̎��_�v�́u#{KU}#{DAKUTEN}#{NOJI}�v�ŕ\���܂����B</li>\r\n"
    end
    if @chuuki_table[:newjis] && !Aozora2Html::Tag::EmbedGaiji.use_jisx0213
      @out.print "\t<li>�u���̎��_�v���̂���JIS X 0213�ɂ��镶���́A�摜�����Ė��ߍ��݂܂����B</li>\r\n"
    end
    if @chuuki_table[:accent] && !Aozora2Html::Tag::Accent.use_jisx0213
      @out.print "\t<li>�A�N�Z���g�����t�����e�������́A�摜�����Ė��ߍ��݂܂����B</li>\r\n"
    end
    if @images[0]
      @out.print "\t<li>���̍�i�ɂ́AJIS X 0213�ɂȂ��A�ȉ��̕������p�����Ă��܂��B�i�����́A��{���̏o���u�y�[�W-�s�v���B�j�����̕����͖{�����ł́u���m���c�n�v�̌`�Ŏ����܂����B</li>\r\n</ul>\r\n<br />\r\n\t\t<table class=\"gaiji_list\">\r\n"
      @images.each{|cell|
       k,*v = cell
       @out.print "			<tr>
				<td>
				#{k}
				</td>
				<td>&nbsp;&nbsp;</td>
				<td>
#{v.join("�A")}				</td>
				<!--
				<td>
				�@�@<img src=\"../../../gaiji/others/xxxx.png\" alt=\"#{k}\" width=32 height=32 />
				</td>
				-->
			</tr>
"
      }
      @out.print "\t\t</table>\r\n"
    else
      @out.print "</ul>\r\n" # <ul>����<li>�ȊO�̃G�������g������͕̂s���Ȃ̂ŏC��
    end
    @out.print "</div>\r\n"
  end
end

if $0 == __FILE__
  # todo: �����`�F�b�N�Ƃ�
  Aozora2Html.new($*[0],$*[1]).process
end
