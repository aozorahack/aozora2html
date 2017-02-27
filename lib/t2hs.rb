# -*- coding:shift_jis -*-
# �󕶌Ɍ`���̃e�L�X�g�t�@�C���� html �ɐ��`���� ruby �X�N���v�g
require "cgi"
require "extensions"
require "aozora2html/error"
require "jstream"
require "aozora2html/tag"
require "aozora2html/tag_parser"
require "aozora2html/accent_parser"

$gaiji_dir = "../../../gaiji/"

$css_files = Array["../../aozora.css"]

# �ϊ���{��
class Aozora2Html

  # �S�p�o�b�N�X���b�V�����o���Ȃ����璼�ł�
  KU = ["18e5"].pack("h*").force_encoding("shift_jis")
  NOJI = ["18f5"].pack("h*").force_encoding("shift_jis")
  DAKUTEN = ["18d8"].pack("h*").force_encoding("shift_jis")

  # KUNOJI = ["18e518f5"].pack("h*")
  # utf8 ["fecbf8fecbcb"].pack("h*")
  # DAKUTENKUNOJI = ["18e518d818f5"].pack("h*")
  # utf8 ["fecbf82e083bfecbcb"].pack("h*")

  ACCENT_TABLE = {
    "!"=>{
      "@"=>["1-09/1-09-03","�t���Q��"]
    },
    "?"=>{
      "@"=>["1-09/1-09-22","�t�^�╄"]
    },
    "A"=>{
      "`"=>["1-09/1-09-23","�O���[�u�A�N�Z���g�t��A"],
      "'"=>["1-09/1-09-24","�A�L���[�g�A�N�Z���g�t��A"],
      "^"=>["1-09/1-09-25","�T�[�J���t���b�N�X�A�N�Z���g�t��"],
      "~"=>["1-09/1-09-26","�`���h�t��A"],
      ":"=>["1-09/1-09-27","�_�C�G���V�X�t��A"],
      "&"=>["1-09/1-09-28","�ナ���O�t��A"],
      "_"=>["1-09/1-09-85","�}�N�����t��A"],
      "E"=>{"&"=>["1-09/1-09-29","���K�`��AE"]}
    },
    "C"=>{
      ","=>["1-09/1-09-30","�Z�f�B���t��C"]
    },
    "E"=>{
      "`"=>["1-09/1-09-31","�O���[�u�A�N�Z���g�t��E"],
      "'"=>["1-09/1-09-32","�A�L���[�g�A�N�Z���g�t��E"],
      "^"=>["1-09/1-09-33","�T�[�J���t���b�N�X�A�N�Z���g�t��E"],
      ":"=>["1-09/1-09-34","�_�C�G���V�X�t��E"],
      "_"=>["1-09/1-09-88","�}�N�����t��E"]
    },
    "I"=>{
      "`"=>["1-09/1-09-35","�O���[�u�A�N�Z���g�t��I"],
      "'"=>["1-09/1-09-36","�A�L���[�g�A�N�Z���g�t��I"],
      "^"=>["1-09/1-09-37","�T�[�J���t���b�N�X�A�N�Z���g�t��I"],
      ":"=>["1-09/1-09-38","�_�C�G���V�X�t��I"],
      "_"=>["1-09/1-09-86","�}�N�����t��I"]
    },
    "N"=>{
      "~"=>["1-09/1-09-40","�`���h�t��N"]
    },
    "O"=>{
      "`"=>["1-09/1-09-41","�O���[�u�A�N�Z���g�t��O"],
      "'"=>["1-09/1-09-42","�A�L���[�g�A�N�Z���g�t��O"],
      "^"=>["1-09/1-09-43","�T�[�J���t���b�N�X�A�N�Z���g�t��O"],
      "~"=>["1-09/1-09-44","�`���h�t��O"],
      ":"=>["1-09/1-09-45","�_�C�G���V�X�t��O"],
      "/"=>["1-09/1-09-46","�X�g���[�N�t��O"],
      "_"=>["1-09/1-09-89","�}�N�����t��O"],
      "E"=>{"&"=>["1-11/1-11-11","���K�`��OE�啶��"]}
    },
    "U"=>{
      "`"=>["1-09/1-09-47","�O���[�u�A�N�Z���g�t��U"],
      "'"=>["1-09/1-09-48","�A�L���[�g�A�N�Z���g�t��U"],
      "^"=>["1-09/1-09-49","�T�[�J���t���b�N�X�A�N�Z���g�t��U"],
      ":"=>["1-09/1-09-50","�_�C�G���V�X�t��U"],
      "_"=>["1-09/1-09-87","�}�N�����t��U"]
    },
    "Y"=>{
      "'"=>["1-09/1-09-51","�A�L���[�g�A�N�Z���g�t��Y"]
    },
    "s"=>{
      "&"=>["1-09/1-09-53","�h�C�c��G�X�c�F�b�g"]
    },
    "a"=>{
      "`"=>["1-09/1-09-54","�O���[�u�A�N�Z���g�t��A������"],
      "'"=>["1-09/1-09-55","�A�L���[�g�A�N�Z���g�t��A������"],
      "^"=>["1-09/1-09-56","�T�[�J���t���b�N�X�A�N�Z���g�t��A������"],
      "~"=>["1-09/1-09-57","�`���h�t��A������"],
      ":"=>["1-09/1-09-58","�_�C�G���V�X�t��A������"],
      "&"=>["1-09/1-09-59","�ナ���O�t��A������"],
      "_"=>["1-09/1-09-90","�}�N�����t��A������"],
      "e"=>{"&"=>["1-09/1-09-60","���K�`��AE������"]}
    },
    "c"=>{
      ","=>["1-09/1-09-61","�Z�f�B���t��C������"]
    },
    "e"=>{
      "`"=>["1-09/1-09-62","�O���[�u�A�N�Z���g�t��E������"],
      "'"=>["1-09/1-09-63","�A�L���[�g�A�N�Z���g�t��E������"],
      "^"=>["1-09/1-09-64","�T�[�J���t���b�N�X�A�N�Z���g�t��E������"],
      ":"=>["1-09/1-09-65","�_�C�G���V�X�t��E������"],
      "_"=>["1-09/1-09-93","�}�N�����t��E������"]
    },
    "i"=>{
      "`"=>["1-09/1-09-66","�O���[�u�A�N�Z���g�t��I������"],
      "'"=>["1-09/1-09-67","�A�L���[�g�A�N�Z���g�t��I������"],
      "^"=>["1-09/1-09-68","�T�[�J���t���b�N�X�A�N�Z���g�t��I������"],
      ":"=>["1-09/1-09-69","�_�C�G���V�X�t��I������"],
      "_"=>["1-09/1-09-91","�}�N�����t��I������"]
    },
    "n"=>{
      "~"=>["1-09/1-09-71","�`���h�t��N������"]
    },
    "o"=>{
      "`"=>["1-09/1-09-72","�O���[�u�A�N�Z���g�t��O������"],
      "'"=>["1-09/1-09-73","�A�L���[�g�A�N�Z���g�t��O������"],
      "^"=>["1-09/1-09-74","�T�[�J���t���b�N�X�A�N�Z���g�t��O������"],
      "~"=>["1-09/1-09-75","�`���h�t��O������"],
      ":"=>["1-09/1-09-76","�_�C�G���V�X�t��O������"],
      "_"=>["1-09/1-09-94","�}�N�����t��O������"],
      "/"=>["1-09/1-09-77","�X�g���[�N�t��O������"],
      "e"=>{"&"=>["1-11/1-11-10","���K�`��OE������"]}
    },
    "u"=>{
      "`"=>["1-09/1-09-78","�O���[�u�A�N�Z���g�t��U������"],
      "'"=>["1-09/1-09-79","�A�L���[�g�A�N�Z���g�t��U������"],
      "^"=>["1-09/1-09-80","�T�[�J���t���b�N�X�A�N�Z���g�t��U������"],
      "_"=>["1-09/1-09-92","�}�N�����t��U������"],
      ":"=>["1-09/1-09-81","�_�C�G���V�X�t��U������"]
    },
    "y"=>{
      "'"=>["1-09/1-09-82","�A�L���[�g�A�N�Z���g�t��Y������"],
      ":"=>["1-09/1-09-84","�_�C�G���V�X�t��Y������"]
    }
  }

  # [class, tag]
  COMMAND_TABLE = {
    "�T�_" => ["sesame_dot","em"],
    "���S�}�T�_" => ["white_sesame_dot","em"],
    "�ۖT�_" => ["black_circle","em"],
    "���ۖT�_" => ["white_circle","em"],
    "���O�p�T�_" => ["black_up-pointing_triangle","em"],
    "���O�p�T�_" => ["white_up-pointing_triangle","em"],
    "��d�ۖT�_" => ["bullseye","em"],
    "�ւ̖ږT�_" => ["fisheye","em"],
    "�΂T�_" => ["saltire", "em"],
    "�T��"=> ["underline_solid","em"],
    "��d�T��"=> ["underline_double","em"],
    "����"=> ["underline_dotted","em"],
    "�j��"=> ["underline_dashed","em"],
    "�g��"=> ["underline_wave","em"],
    "����"=> ["futoji","span"],
    "�Α�"=> ["shatai","span"],
    "���t��������"=>["subscript","sub"],
    "��t��������"=>["superscript","sup"],
    "�s�E������"=>["superscript","sup"],
    "�s��������"=>["subscript","sub"]
  }

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
    @ruby_buf = [""]
    @ruby_char_type = nil
    @section = :head
    @header = []
    @style_stack = []
    @chuuki_table = {}
    @images = []
    @indent_stack = []
    @tag_stack = []
    @midashi_id = 0
    @terprip = true
    @endchar = :eof
    @ruby_buf_protected = nil
    @ruby_buf_type = nil
  end

  def scount
    @stream.line
  end

  def block_allowed_context?
    # inline_tag���J���Ă��Ȃ����`�F�b�N����Ώ\��
    not(@style_stack.last)
  end

  def read_char
    @stream.read_char
  end

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
    Aozora2Html::AccentParser.new(@stream, "�l", @chuuki_table, @images).process
  end

  def read_to_nest(endchar)
    Aozora2Html::TagParser.new(@stream, endchar, @chuuki_table, @images).process
  end

  def read_line
    tmp = read_to("\r\n")
    @buffer = []
    tmp
  end

  def process
    catch(:terminate) do
      loop do
        begin
          parse
        rescue Aozora2Html::Error => e
          puts e.message(scount)
          if e.is_a?(Aozora2Html::Error)
            exit(2)
          end
        end
      end
    end
    tail_output # final call
    finalize
    close
  end

  def char_type(char)
    if char.is_a?(Aozora2Html::Tag::Accent)
      :hankaku
    elsif char.is_a?(Aozora2Html::Tag::Gaiji)
      :kanji
    elsif char.is_a?(Aozora2Html::Tag::Kunten) # just remove this line
      :else
    elsif char.is_a?(Aozora2Html::Tag::DakutenKatakana)
      :katakana
    elsif char.is_a?(Aozora2Html::Tag)
      :else
    elsif char.match(/[��-��T�U]/)
      :hiragana
    elsif char.match(/[�@-���[�R�S��]/)
      :katakana
    elsif char.match(/[�O-�X�`-�y��-����-����-�ք@-�`�p-���|���f�C�D]/)
      :zenkaku
    elsif char.match(/[A-Za-z0-9#\-\&'\,]/)
      :hankaku
    elsif char.match(/[��-꤁X���W�Y�Z��]/)
      :kanji
    elsif char.match(/[\.\;\"\?\!\)]/)
      :hankaku_terminate
    else
      :else
    end
  end

  def finalize
    hyoki
    dynamic_contents
    @out.print("</body>\r\n</html>\r\n")
  end

  def dynamic_contents
    @out.print "<div id=\"card\">\r\n<hr />\r\n<br />\r\n" +
               "<a href=\"JavaScript:goLibCard();\" id=\"goAZLibCard\">���}���J�[�h</a>" +
               "<script type=\"text/javascript\" src=\"../../contents.js\"></script>\r\n" +
               "<script type=\"text/javascript\" src=\"../../golibcard.js\"></script>\r\n" +
               "</div>"
  end

  def close
    @stream.close
    @out.close
  end

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

  def ensure_close
    if n = @indent_stack.last
      raise Aozora2Html::Error.new("#{convert_indent_type(n)}���ɖ{�����I�����܂���")
    end
  end

  def explicit_close(type)
    n = check_close_match(type)
    if n
      raise Aozora2Html::Error.new("#{n}����悤�Ƃ��܂������A#{n}���ł͂���܂���")
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
      Aozora2Html::Error.new("encount undefined condition")
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
        @section = :chuuki
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
      process_header
    else
      string.gsub!(/�b/,"")
      string.gsub!(/�s.*?�t/,"")
      @header.push(string)
    end
  end

  def html_title_push(string, hash, attr)
    found = hash[attr]
    if found
      if found != ""
        string + " " + found
      else
        found
      end
    else
      string
    end
  end

  def out_header_info(hash, attr, true_name = nil)
    found = hash[attr]
    if found
      @out.print("<h2 class=\"#{true_name or attr}\">#{found}</h2>\r\n")
    end
  end

  def header_element_type(string)
    original = true
    string.each_char do |x|
      code = x.unpack("H*")[0]
      if ("00" <= code and code <= "7f") or # 1byte
          ("8140" <= code and code <= "8258") or # 1-1, 3-25
          ("839f" <= code and code <= "8491") # 6-1, 7-81
        # continue
      else
        original = false
        break
      end
    end
    if original
      :original
    elsif string.match(/[�Z��|��|�ҏW|�ҏW�Z��|�Z���ҏW]$/)
      :editor
    elsif string.match(/�Җ�$/)
      :henyaku
    elsif string.match(/��$/)
      :translator
    end
  end

  def process_person(string, header_info)
    type = header_element_type(string)
    case type
    when :editor
      header_info[:editor] = string
    when :translator
      header_info[:translator] = string
    when :henyaku
      header_info[:henyaku] = string
    else
      type = :author
      header_info[:author] = string
    end
    type
  end

  def process_header
    header_info = {:title => @header[0]}
    case @header.length
    when 2
      process_person(@header[1], header_info)
    when 3
      if header_element_type(@header[1]) == :original
        header_info[:original_title] = @header[1]
        process_person(@header[2], header_info)
      elsif process_person(@header[2], header_info) == :author
        header_info[:subtitle] = @header[1]
      else
        header_info[:author] = @header[1]
      end
    when 4
      if header_element_type(@header[1]) == :original
        header_info[:original_title] = @header[1]
      else
        header_info[:subtitle] = @header[1]
      end
      if process_person(@header[3], header_info) == :author
        header_info[:subtitle] = @header[2]
      else
        header_info[:author] = @header[2]
      end
    when 5
      header_info[:original_title] = @header[1]
      header_info[:subtitle] = @header[2]
      header_info[:author] = @header[3]
      if process_person(@header[4], header_info) == :author
        raise Aozora2Html::Error.new("parser encounted author twice")
      end
    when 6
      header_info[:original_title] = @header[1]
      header_info[:subtitle] = @header[2]
      header_info[:original_subtitle] = @header[3]
      header_info[:author] = @header[4]
      if process_person(@header[5], header_info) == :author
        raise Aozora2Html::Error.new("parser encounted author twice")
      end
    end

    # <title> �s���\�z
    html_title = "<title>#{header_info[:author]}"
    html_title = html_title_push(html_title, header_info, :translator)
    html_title = html_title_push(html_title, header_info, :editor)
    html_title = html_title_push(html_title, header_info, :henyaku)
    html_title = html_title_push(html_title, header_info, :title)
    html_title = html_title_push(html_title, header_info, :original_title)
    html_title = html_title_push(html_title, header_info, :subtitle)
    html_title = html_title_push(html_title, header_info, :original_subtitle)
    html_title += "</title>"

    # �o��
    @out.print("<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"\r\n    \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\r\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" >\r\n<head>\r\n	<meta http-equiv=\"Content-Type\" content=\"text/html;charset=Shift_JIS\" />\r\n	<meta http-equiv=\"content-style-type\" content=\"text/css\" />\r\n")
    $css_files.each do |css|
      @out.print("\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + css + "\" />\r\n")
    end
    @out.print("\t#{html_title}\r\n	<script type=\"text/javascript\" src=\"../../jquery-1.4.2.min.js\"></script>\r\n  <link rel=\"Schema.DC\" href=\"http://purl.org/dc/elements/1.1/\" />\r\n	<meta name=\"DC.Title\" content=\"#{header_info[:title]}\" />\r\n	<meta name=\"DC.Creator\" content=\"#{header_info[:author]}\" />\r\n	<meta name=\"DC.Publisher\" content=\"�󕶌�\" />\r\n</head>\r\n<body>\r\n<div class=\"metadata\">\r\n")
    @out.print("<h1 class=\"title\">#{header_info[:title]}</h1>\r\n")
    out_header_info(header_info, :original_title)
    out_header_info(header_info, :subtitle)
    out_header_info(header_info, :original_subtitle)
    out_header_info(header_info, :author)
    out_header_info(header_info, :editor)
    out_header_info(header_info, :translator)
    out_header_info(header_info, :henyaku, "editor-translator")
    @out.print("<br />\r\n<br />\r\n</div>\r\n<div id=\"contents\" style=\"display:none\"></div><div class=\"main_text\">")
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

  def illegal_char_check(char, line)
    if char.is_a?(String)
      code = char.unpack("H*")[0]
      if (code == "21" or
          code == "23" or
          ("a1" <= code and code <= "a5") or
          ("28" <= code and code <= "29") or
          code == "5b" or
          code == "5d" or
          code == "3d" or
          code == "3f" or
          code == "2b" or
          ("7b" <= code and code <= "7d"))
        puts "�x��(#{line}�s��):1�o�C�g�́u#{char}�v���g���Ă��܂�"
      end

      if code == "81f2"
        puts "�x��(#{line}�s��):���L�L���̌�p�̉\��������A�u#{char}�v���g���Ă��܂�"
      end

      if (("81ad" <=  code and code <= "81b7") or
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
          ("ef40" <=  code and code <= "effc"))
        puts "�x��(#{line}�s��):JIS�O���u#{char}�v���g���Ă��܂�"
      end
    end
  end

  # �{�̉�͕�
  # 1�������ǂݍ��݁Adispatch����@buffer,@ruby_buf�ւ��܂�
  # ���s�R�[�h�ɓ��������痭�ߍ��񂾂��̂�general_output����

  def parse_body
    char = read_char
    check = true
    case char
    when "�k"
      check = false
      char = read_accent
    when "��"
      if @buffer.length == 0
        ending_check
      end
    when "��"
      char = dispatch_gaiji
    when "�m"
      char = dispatch_aozora_command
    when KU
      assign_kunoji
    when "�s"
      char = apply_ruby
    end

    if char == "\r\n"
      general_output
    elsif char == "�b"
      ruby_buf_dump
      @ruby_buf_protected = true
    elsif char == @endchar
      # suddenly finished the file
      puts "�x��(#{scount}�s��):�\�����ʃt�@�C���I�["
      throw :terminate
    elsif char != nil
      if check
        illegal_char_check(char, scount)
      end
      push_chars(char)
    end
  end

  def ending_check
    if @stream.peek_char(0) == "�{" and @stream.peek_char(1) == "�F"
      @section = :tail
      ensure_close
      @out.print "</div>\r\n<div class=\"bibliographical_information\">\r\n<hr />\r\n<br />\r\n"
    end
  end

  # buffer management
  def ruby_buf_dump
    if @ruby_buf_protected
      @ruby_buf.unshift("�b")
      @ruby_buf_protected = nil
    end
    top = @ruby_buf[0]
    if top.is_a?(String) and @buffer.last.is_a?(String)
      @buffer.last.concat(top)
      @buffer = @buffer + @ruby_buf[1,@ruby_buf.length]
    else
      @buffer = @buffer + @ruby_buf
    end
    @ruby_buf = [""]
  end

  def push_chars(obj)
    if obj.is_a?(Array)
      obj.each{|x|
        push_chars(x)
      }
    elsif obj.is_a?(String)
      if obj.length == 1
        obj = obj.gsub(/[&\"<>]/, {'&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;'})
      end
      obj.each_char{|x|
        push_char(x)
      }
    else
      push_char(obj)
    end
  end

  def push_char(char)
   ctype = char_type(char)
    if ctype == :hankaku_terminate and @ruby_buf_type == :hankaku
      if @ruby_buf.last.is_a?(String)
        @ruby_buf.last.concat(char)
      else
        @ruby_buf.push(char)
      end
      @ruby_buf_type = :else
    elsif @ruby_buf_protected or (ctype != :else and ctype == @ruby_buf_type)
      if char.is_a?(String) and @ruby_buf.last.is_a?(String)
        @ruby_buf.last.concat(char)
      else
        @ruby_buf.push(char)
        @ruby_buf.push("")
      end
    else
      ruby_buf_dump
      @ruby_buf_type = ctype
      @ruby_buf = [char]
    end
  end

  def buf_is_blank?(buf)
    buf.each{|token|
      if token.is_a?(String) and not(token=="")
        return false
      elsif token.is_a?(Aozora2Html::Tag::OnelineIndent)
        return :inline
      end
    }
    true
  end

  def terpri?(buf)
    flag = true
    buf.each{|x|
      if x.is_a?(Aozora2Html::Tag::Multiline)
        flag = false
      elsif (x.is_a?(String) and x == "")
        nil
      else
        return true
      end
    }
    flag
  end

  def general_output
    if @style_stack.last
      raise Aozora2Html::Error.new("#{@style_stack.last[0]}���ɉ��s����܂����B���s���܂����v�f�ɂ̓u���b�N�\�L��p���Ă�������")
    end
    # buffer�ɃC���f���g�^�O����������������s���Ȃ��I
    if @noprint
      @noprint = false
      return
    end
    ruby_buf_dump
    buf = @buffer
    @ruby_buf = [""]; @ruby_buf_mode = nil; @buffer = []
    tail = []

    indent_type = buf_is_blank?(buf)
    terprip = (terpri?(buf) and @terprip)
    @terprip = true

    if @indent_stack.last.is_a?(String) and not(indent_type)
      @out.print @indent_stack.last
    end

    buf.each{|s|
      if s.is_a?(Aozora2Html::Tag::OnelineIndent)
        tail.unshift(s.close_tag)
      elsif s.is_a?(Aozora2Html::Tag::UnEmbedGaiji) and not(s.escaped?)
        # �����Ă��������𕜊�������
        @out.print "��"
      elsif s.is_a?(Aozora2Html::Tag::MultilineChitsuki)
      elsif s.is_a?(String) and s.match("</em")
      end
      @out.print s.to_s
    }
    if @indent_stack.last.is_a?(String)
      # �Ԃ牺��indent
      # tail always active
      if tail.last
        tail.each{|s|
          @out.print s.to_s
        }
      end
      if indent_type == :inline
        @out.print "\r\n"
      elsif indent_type and terprip
        @out.print "<br />\r\n"
      else
        @out.print "</div>\r\n"
      end
    elsif tail.last
      tail.each{|s|
        @out.print s.to_s
      }
      @out.print "\r\n"
    elsif terprip
      @out.print "<br />\r\n"
    else
      @out.print "\r\n"
    end
  end

  # �O���Q�Ƃ̔��� Ruby,style�d�˂������X�̂��߁A�v�f�̔z��ŕԂ�
  def search_front_reference(string)
    if string.length == 0
      return false
    end
    searching_buf = if @ruby_buf.length != 0
                      @ruby_buf
                    else
                      @buffer
                    end
    last_string = searching_buf.last
    if last_string.is_a?(String)
      if last_string == ""
        searching_buf.pop
        search_front_reference(string.sub(Regexp.new(Regexp.quote(last_string)+"$"),""))
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
  def recovery_front_reference(reference)
    reference.each{|elt|
#      if @ruby_buf_protected
      if @ruby_buf.length > 0
        if @ruby_buf.last.is_a?(String)
          if elt.is_a?(String)
            @ruby_buf.last.concat(elt)
          else
            @ruby_buf.push(elt)
          end
        else
          @ruby_buf.push(elt)
        end
      else
        if @buffer.last.is_a?(String)
          if elt.is_a?(String)
            @buffer.last.concat(elt)
          else
            @buffer.push(elt)
          end
        else
          @ruby_buf.push(elt)
        end
      end
    }
  end

  def convert_japanese_number(command)
    tmp = command.tr("�O-�X", "0-9")
    tmp.tr!("���O�l�ܘZ������Z","1234567890")
    tmp.gsub!(/(\d)�\(\d)/){"#{$1}#{$2}"}
    tmp.gsub!(/(\d)�\/){"#{$1}0"}
    tmp.gsub!(/�\(\d)/){"1#{$1}"}
    tmp.gsub!(/�\/,"10")
    tmp
  end

  def kuten2png(substring)
    desc = substring.gsub(/�u���v[��|��]/,"")
    match = desc.match(/[12]\-\d{1,2}\-\d{1,2}/)
    if (match and not(desc.match(/��0213�O��/)) and not(desc.match(/��.*��/)))
      @chuuki_table[:newjis] = true
      codes = match[0].split("-")
      folder = sprintf("%1d-%02d",*codes)
      code = sprintf("%1d-%02d-%02d",*codes)
      Aozora2Html::Tag::EmbedGaiji.new(self, folder, code, desc.gsub!("��",""))
    else
      substring
    end
  end

  def escape_gaiji(command)
    _whole, kanji, line = command.match(/(?:��)(.*)(?:�A)(.*)/).to_a
    tmp = @images.assoc(kanji)
    if tmp
      tmp.push(line)
    else
      @images.push([kanji, line])
    end
    Aozora2Html::Tag::UnEmbedGaiji.new(self, command)
  end

  def dispatch_gaiji
    hook = @stream.peek_char(0)
    if hook ==  "�m"
      read_char
      # embed?
      command, _raw = read_to_nest("�n")
      try_emb = kuten2png(command)
      if try_emb != command
        try_emb
      elsif command.match(/U\+([0-9A-F]{4,5})/) && Aozora2Html::Tag::EmbedGaiji.use_unicode
        unicode_num = $1
        ch = Aozora2Html::Tag::EmbedGaiji.new(self, nil, nil, command)
        ch.unicode = unicode_num
        ch
      else
        # Unemb
        escape_gaiji(command)
      end
    else
      "��"
    end
  end

  def dispatch_aozora_command
    if @stream.peek_char(0) != "��"
      "�m"
    else
      read_char
      command,raw = read_to_nest("�n")
      # �K�p�����͂���ő��v���H�@�딚�|����딚
      if command.match(/�܂�Ԃ���/)
        apply_burasage(command)

      elsif command.match(/^��������/)
        exec_block_start_command(command.sub(/^��������/,""))
      elsif command.match(/^������/)
        exec_block_end_command(command.sub(/^������/,""))

      elsif command.match(/���蒍/)
        apply_warichu(command)
      elsif command.match(/������/)
        apply_jisage(command)
      elsif command.match(/fig(\d)+_(\d)+\.png/)
        exec_img_command(command,raw)
      # avoid to try complex ruby -- escape to notes
      elsif command.match(/(��|��)�Ɂu(.*)�v��(���r|���L|�T�L)/)
        apply_rest_notes(command)
      elsif command.match(/�I���$/)
        exec_inline_end_command(command)
        nil
      elsif command.match(/^�u.+�v/)
        exec_frontref_command(command)
      elsif command.match(/1-7-8[2345]/)
        apply_dakuten_katakana(command)
      elsif command.match(/^([���O�l�ܘZ������\���㒆���b�������V�n�l]+)$/)
        Aozora2Html::Tag::Kaeriten.new(self, command)
      elsif command.match(/^�i(.+)�j$/)
        Aozora2Html::Tag::Okurigana.new(self, command.gsub!(/[�i�j]/,""))
      elsif command.match(/(�n�t��|���グ)(�I���)*$/)
        apply_chitsuki(command)
      elsif exec_inline_start_command(command)
        nil
      else
        apply_rest_notes(command)
      end
    end
  end

  def apply_burasage(command)
    tag = nil
    if implicit_close(:jisage)
      @terprip = false
      general_output
    end
    @noprint = true # always no print
    command = convert_japanese_number(command)
    if command.match(/�V�t��/)
      width = command.match(/�܂�Ԃ���(\d*)������/)[1]
      tag = '<div class="burasage" style="margin-left: ' + width + 'em; text-indent: -' + width  + 'em;">'
    else
      match = command.match(/(\d*)�������A�܂�Ԃ���(\d*)������/)
      left, indent = match.to_a[1,2]
      left = left.to_i - indent.to_i
      tag = "<div class=\"burasage\" style=\"margin-left: #{indent}em; text-indent: #{left}em;\">"
    end
    @indent_stack.push(tag)
    @tag_stack.push("") # dummy
    nil
  end

  def jisage_width(command)
    convert_japanese_number(command).match(/(\d*)(?:������)/)[1]
  end

  def apply_jisage(command)
    if command.match(/�܂�/) or command.match(/�I���/)
      # �������I���
      explicit_close(:jisage)
      @indent_stack.pop
      nil
    else
      if command.match(/���̍s/)
        # 1�s����
        @buffer.unshift(Aozora2Html::Tag::OnelineJisage.new(self, jisage_width(command)))
        nil
      else
        if @buffer.length == 0 and @stream.peek_char(0) == "\r\n"
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
    end
  end

  def apply_warichu(command)
    if command.match(/�I���/)
      check = @stream.peek_char(0)
      if check == "�j"
        push_chars('</span>')
      else
        push_chars('�j')
        push_chars('</span>')
      end
    else
      check = @ruby_buf.last
      if check.is_a?(String) and check.match(/�i$/)
        push_chars('<span class="warichu">')
      else
        push_chars('<span class="warichu">')
        push_chars('�i')
      end
    end
    nil
  end

  def chitsuki_length(command)
    command = convert_japanese_number(command)
    if match = command.match(/([0-9]+)��/)
      match[1]
    else
      "0"
    end
  end

  def apply_chitsuki(string, multiline = false)
    if string.match(/�����Œn�t���I���/) or
        string.match(/�����Ŏ��グ�I���/)
      explicit_close(:chitsuki)
      @indent_stack.pop
      nil
    else
      l = chitsuki_length(string)
      if multiline
        # �����s�w��
        implicit_close(:chitsuki)
        @indent_stack.push(:chitsuki)
        Aozora2Html::Tag::MultilineChitsuki.new(self, l)
      else
        # 1�s�̂�
        Aozora2Html::Tag::OnelineChitsuki.new(self, l)
      end
    end
  end

  def new_midashi_id(inc)
    @midashi_id += inc
  end

  def apply_midashi(command)
    @indent_stack.push(:midashi)
      midashi_type = :normal
      if command.match(/���s/)
        midashi_type = :dogyo
      elsif command.match(/��/)
        midashi_type = :mado
      else
        @terprip = false
      end
    Aozora2Html::Tag::MultilineMidashi.new(self,command,midashi_type)
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
    w = convert_japanese_number(command).match(/(\d*)(?:���l��)/)[1]
    @indent_stack.push(:jizume)
    Aozora2Html::Tag::Jizume.new(self, w)
  end

  def push_block_tag(tag,closing)
    push_chars(tag)
    closing.concat(tag.close_tag)
  end

  def exec_inline_start_command(command)
    case command
    when "���L�t��"
      @style_stack.push([command,'</ruby>'])
      push_char('<ruby><rb>')
    when "�c����"
      @style_stack.push([command,'</span>'])
      push_char('<span dir="ltr">')
    when "�r�͂�"
      @style_stack.push([command,'</span>'])
      push_chars('<span class="keigakomi">')
    when "���g��"
      @style_stack.push([command,'</span>'])
      push_chars('<span class="yokogumi">')
    when "�L���v�V����"
      @style_stack.push([command,'</span>'])
      push_chars('<span class="caption">')
    when "�匩�o��"
      @style_stack.push([command,'</a></h3>'])
      @terprip = false
      push_chars("<h3 class=\"o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when "�����o��"
      @style_stack.push([command,'</a></h4>'])
      @terprip = false
      push_chars("<h4 class=\"naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when "�����o��"
      @style_stack.push([command,'</a></h5>'])
      @terprip = false
      push_chars("<h5 class=\"ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    when "���s�匩�o��"
      @style_stack.push([command,'</a></h3>'])
      push_chars("<h3 class=\"dogyo-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when "���s�����o��"
      @style_stack.push([command,'</a></h4>'])
      push_chars("<h4 class=\"dogyo-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when "���s�����o��"
      @style_stack.push([command,'</a></h5>'])
      push_chars("<h5 class=\"dogyo-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    when "���匩�o��"
      @style_stack.push([command,'</a></h3>'])
      push_chars("<h3 class=\"mado-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(100)}\">")
    when "�������o��"
      @style_stack.push([command,'</a></h4>'])
      push_chars("<h4 class=\"mado-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(10)}\">")
    when "�������o��"
      @style_stack.push([command,'</a></h5>'])
      push_chars("<h5 class=\"mado-ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi#{new_midashi_id(1)}\">")
    else
      if command.match(/(.*)�i�K(..)�ȕ���/)
        @style_stack.push([command,'</span>'])
        _whole, nest, style = command.match(/(.*)�i�K(..)�ȕ���/).to_a
        times = convert_japanese_number(nest).to_i
        daisho = if style.match("��")
                   :sho
                 else
                   :dai
                 end
        html_class = daisho.to_s + times.to_s
        size = case times
               when 1
                 ""
               when 2
                 "x-"
               else
                 if times >= 3
                   "xx-"
                 else
                   raise Aozora2Html::Error.new("�����T�C�Y�̎w�肪�s���ł�")
                 end
               end + case daisho
                     when :dai
                       "large"
                     when :sho
                       "small"
                     end
        push_chars("<span class=\"#{html_class}\" style=\"font-size: #{size};\">")
      else
        ## Decoration ##
        key = command
        filter = lambda{|x| x}
        if command.match(/(�E|��|��|��)��(.*)/)
          _whole, dir, com = command.match(/(�E|��|��|��)��(.*)/).to_a
          # renew command
          key = com
          if command.match(/�_/)
            case dir
            when "��", "��"
              filter = lambda{|x| x + "_after"}
            end
          elsif command.match(/��/)
            case dir
            when "��", "��"
              filter = lambda{|x| x.sub("under","over")}
            end
          end
        end

        found = COMMAND_TABLE[key]
        # found = [class, tag]
        if found
          @style_stack.push([command,"</#{found[1]}>"])
          if found[1] == "em" # or found[1] == "strong"
            @chuuki_table[:em] = true
          end
          push_chars("<#{found[1]} class=\"#{filter.call(found[0])}\">")
        else
          nil
        end
      end
    end
  end

  def exec_inline_end_command(command)
    encount = command.sub("�I���","")
    if encount == "�{��"
      # force to finish main_text
      @section = :tail
      ensure_close
      @noprint = true
      @out.print "</div>\r\n<div class=\"after_text\">\r\n<hr />\r\n"
    elsif encount.match("���L�t��") and @style_stack.last[0] == "���L�t��"
      # special inline ruby
      @style_stack.pop
      _whole, ruby = encount.match("�u(.*)�v�̒��L�t��").to_a
      push_char("</rb><rp>�i</rp><rt>#{ruby}</rt><rp>�j</rp></ruby>")
    elsif @style_stack.last[0].match(encount)
      push_chars(@style_stack.pop[1])
    else
      raise Aozora2Html::Error.new("#{encount}���I�����悤�Ƃ��܂������A#{@style_stack.last[0]}���ł�")
    end
  end

  def exec_block_start_command(command)
    match = ""
    if command.match(/������/)
      push_block_tag(apply_jisage(command),match)
    elsif command.match(/(�n�t��|���グ)$/)
      push_block_tag(apply_chitsuki(command,true),match)
    end

    if command.match(/���o��/)
      push_block_tag(apply_midashi(command),match)
    end

    if command.match(/���l��/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_jizume(command),match)
    end

    if command.match(/���g��/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_yokogumi(command),match)
    end

    if command.match(/�r�͂�/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_keigakomi(command),match)
    end

    if command.match(/�L���v�V����/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(apply_caption(command),match)
    end

    if command.match(/����/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, "futoji"),match)
      @indent_stack.push(:futoji)
    end
    if command.match(/�Α�/)
      if match != ""
        @indent_stack.pop
      end
      push_block_tag(Aozora2Html::Tag::MultilineStyle.new(self, "shatai"),match)
      @indent_stack.push(:shatai)
    end

    if command.match(/(.*)�i�K(..)�ȕ���/)
      _whole, nest, style = command.match(/(.*)�i�K(..)�ȕ���/).to_a
      if match != ""
        @indent_stack.pop
      end
      daisho = if style == "����"
                 :sho
               else
                 :dai
               end
      push_block_tag(Aozora2Html::Tag::FontSize.new(self,
                                       convert_japanese_number(nest).to_i,
                                       daisho),match)
      @indent_stack.push(daisho)
    end

    if match == ""
      apply_rest_notes("��������" + command)
    else
      @tag_stack.push(match)
      nil
    end
  end

  def exec_block_end_command(command)
    match = false
    if mode = if command.match(/������/)
                :jisage
              elsif command.match(/(�n�t��|���グ)�I���$/)
                :chitsuki
              elsif command.match(/���o��/)
                :midashi
              elsif command.match(/���l��/)
                :jizume
              elsif command.match(/���g��/)
                :yokogumi
              elsif command.match(/�r�͂�/)
                :keigakomi
              elsif command.match(/�L���v�V����/)
                :caption
              elsif command.match(/����/)
                :futoji
              elsif command.match(/�Α�/)
                :shatai
              elsif command.match(/�傫�ȕ���/)
                :dai
              elsif command.match(/�����ȕ���/)
                :sho
              end
      explicit_close(mode)
      match = @indent_stack.pop
    end

    if match
      if not(match.is_a?(String))
        @terprip = false
      end
      nil
    else
      apply_rest_notes("������" + command)
    end
  end

  def exec_img_command(command,raw)
    match = raw.match(/(.*)�i(fig.+\.png)(�A��([0-9]+)�~�c([0-9]+))*�j����/)
    if match
      _whole, alt, src, _wh, width, height = match.to_a
      css_class = if alt.match(/�ʐ^/)
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
    _whole, reference, spec1, spec2 = command.match(/�u([^�u�v]*(?:�u.+�v)*[^�u�v]*)�v[��|��|��](�u.+�v��)*(.+)/).to_a
    spec = if spec1
             spec1 + spec2
           else
             spec2
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

  def multiply(bouki, times)
    s = ""
    (times-1).times{
      s += bouki
      s += "<!>"
    }
    s + bouki
  end

  def include_ruby?(array)
    array.index{|elt|
      if elt.is_a?(Aozora2Html::Tag::Ruby)
        true
      elsif elt.is_a?(Aozora2Html::Tag::ReferenceMentioned)
        if elt.target.is_a?(Array)
          include_ruby?(elt.target)
        else
          elt.target.is_a?(Aozora2Html::Tag::Ruby)
        end
      end
    }
  end

  # complex ruby wrap up utilities -- don't erase! we will use soon ...
  def rearrange_ruby_tag(targets, upper_ruby, under_ruby = "")
    target,upper,under = rearrange_ruby(targets, upper_ruby, under_ruby)
    Aozora2Html::Tag::Ruby.new(self, target,upper,under)
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
        raise Aozora2Html::Error.new("1�̒P���3�̃��r�͂����܂���")
      end

      targets.each{|x|
        if x.is_a?(Aozora2Html::Tag::Ruby)
          if x.target.is_a?(Array)
            # inner Aozora2Html::Tag::Ruby is already complex ... give up
            raise Aozora2Html::Error.new("�����ӏ���2�̃��r�͂����܂���")
          else
            if x.ruby != ""
              if new_upper.is_a?(Array)
                new_upper.push(x.ruby)
              else
              raise Aozora2Html::Error.new("�����ӏ���2�̃��r�͂����܂���")
              end
            else
              if new_under.is_a?(Array)
              new_under.push(x.under_ruby)
              else
                raise Aozora2Html::Error.new("�����ӏ���2�̃��r�͂����܂���")
              end
            end
            new_targets.push(x.target)
          end
        elsif x.is_a?(Aozora2Html::Tag::ReferenceMentioned)
          if x.target.is_a?(Array)
            # recursive
            tar,up,un = rearrange_ruby(x.target,"","")
            # rotation!!
            tar.each{|y|
              tmp = x.dup
              tmp.target = y
              new_targets.push(tmp)}
            if new_under.is_a?(Array)
              new_under.concat(un)
            elsif un.to_s.length > 0
              raise Aozora2Html::Error.new("�����ӏ���2�̃��r�͂����܂���")
            end
            if new_upper.is_a?(Array)
              new_upper.concat(up)
            elsif up.to_s.length > 0
              raise Aozora2Html::Error.new("�����ӏ���2�̃��r�͂����܂���")
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
    elsif command.match(/�c����/)
      Aozora2Html::Tag::Dir.new(self, targets)
    elsif command.match(/���g��/)
      Aozora2Html::Tag::InlineYokogumi.new(self, targets)
    elsif command.match(/�r�͂�/)
      Aozora2Html::Tag::InlineKeigakomi.new(self, targets)
    elsif command.match(/�L���v�V����/)
      Aozora2Html::Tag::InlineCaption.new(self, targets)
    elsif command.match(/�Ԃ�_/)
      Aozora2Html::Tag::Kaeriten.new(self, targets)
    elsif command.match(/�P�_���艼��/)
      Aozora2Html::Tag::Okurigana.new(self, targets)
    elsif command.match(/���o��/)
      midashi_type = :normal
      if command.match(/���s/)
        midashi_type = :dogyo
      elsif command.match(/��/)
        midashi_type = :mado
      else
        @terprip = false
      end
      Aozora2Html::Tag::Midashi.new(self, targets, command, midashi_type)
    elsif command.match(/(.*)�i�K(..)�ȕ���/)
      _whole, nest, style = command.match(/(.*)�i�K(..)�ȕ���/).to_a
      Aozora2Html::Tag::InlineFontSize.new(self,targets,
                               convert_japanese_number(nest).to_i,
                               if style.match("��")
                                 :sho
                               else
                                 :dai
                               end)
    elsif command.match(/(��|��)�Ɂu([^�v]*)�v��(���r|���L)/)
      _whole, dir, under = command.match(/(��|��)�Ɂu([^�v]*)�v��(���r|���L)/).to_a
      if targets.length == 1 and targets[0].is_a?(Aozora2Html::Tag::Ruby)
        tag = targets[0]
        if tag.under_ruby == ""
          tag.under_ruby = under
          tag
        else
          raise Aozora2Html::Error.new("1�̒P���3�̃��r�͂����܂���")
        end
      else
        rearrange_ruby_tag(targets,"",under)
      end
    elsif command.match(/�u(.+?)�v�̒��L/)
      rearrange_ruby_tag(targets,/�u(.+?)�v�̒��L/.match(command).to_a[1])
    elsif command.match(/�u(.)�v�̖T�L/)
      rearrange_ruby_tag(targets,multiply( /�u(.)�v�̖T�L/.match(command).to_a[1], target.length))
    else
      ## direction fix! ##
      filter = lambda{|x| x}
      if command.match(/(�E|��|��|��)��(.*)/)
        _whole, dir, com = command.match(/(�E|��|��|��)��(.*)/).to_a
        # renew command
        command = com
        if command.match(/�_/)
          case dir
          when "��", "��"
            filter = lambda{|x| x + "_after"}
          end
        elsif command.match(/��/)
          case dir
          when "��", "��"
            filter = lambda{|x| x.sub("under","over")}
          end
        end
      end

      found = COMMAND_TABLE[command]
      # found = [class, tag]
      if found
        if found[1] == "em" # or found[1] == "strong"
          @chuuki_table[:em] = true
        end
        Aozora2Html::Tag::Decorate.new(self, targets, filter.call(found[0]), found[1])
      else
        nil
      end
    end
  end

  def apply_dakuten_katakana(command)
    n = command.match(/1-7-8([2345])/).to_a[1]
    frontref =
      case n
        when "2"
        "���J"
        when "3"
        "���J"
        when "4"
        "���J"
        when "5"
        "���J"
      end
    if found = search_front_reference(frontref)
      Aozora2Html::Tag::DakutenKatakana.new(self, n,found.join)
    else
      apply_rest_notes(command)
    end
  end

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
    @ruby_buf_protected = nil
    ruby, _raw = read_to_nest("�t")
    if ruby.length == 0
      # escaped ruby character
      return "�s�t"
    end
    ans = ""
    notes = []
    @ruby_buf.each{|token|
      if token.is_a?(Aozora2Html::Tag::UnEmbedGaiji)
        ans.concat("��")
        token.escape!
        notes.push(token)
      else
        ans.concat(token.to_s)
      end}
    @buffer.push(Aozora2Html::Tag::Ruby.new(self, ans, ruby))
    @buffer = @buffer + notes
    @ruby_buf = [""]
    nil
  end

  def parse_tail
    char = read_char
    check = true
    case char
    when "�k"
      check = false
      char = read_accent
    when @endchar
        throw :terminate
    when "��"
      char = dispatch_gaiji
    when "�m"
      char = dispatch_aozora_command
    when KU
        assign_kunoji
    when "�s"
      char = apply_ruby
    end
    if char == "\r\n"
      tail_output
    elsif char == "�b"
      ruby_buf_dump
      @ruby_buf_protected = true
    elsif char != nil
      if check
        illegal_char_check(char, scount)
      end
      push_chars(char)
    end
  end

  def tail_output
    ruby_buf_dump
    string = @buffer.join
    @ruby_buf = [""]; @ruby_buf_mode = nil; @buffer = []
    string.gsub!("info@aozora.gr.jp",'<a href="mailto: info@aozora.gr.jp">info@aozora.gr.jp</a>')
    string.gsub!("�󕶌Ɂihttp://www.aozora.gr.jp/�j"){"<a href=\"http://www.aozora.gr.jp/\">#{$&}</a>"}
    if string.match(/(<br \/>$|<\/p>$|<\/h\d>$|<div.*>$|<\/div>$|^<[^>]*>$)/)
      @out.print string, "\r\n"
    else
      @out.print string, "<br />\r\n"
    end
  end

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
    if @chuuki_table[:newjis]
      @out.print "\t<li>�u���̎��_�v���̂���JIS X 0213�ɂ��镶���́A�摜�����Ė��ߍ��݂܂����B</li>\r\n"
    end
    if @chuuki_table[:accent]
      @out.print "\t<li>�A�N�Z���g�����t�����e�������́A�摜�����Ė��ߍ��݂܂����B</li>\r\n"
    end
#    if @chuuki_table[:em]
#      @out.print "\t<li>�T�_�⌗�_�A�T���̕t���������́A�����\���ɂ��܂����B</li>\r\n"
#   end
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
