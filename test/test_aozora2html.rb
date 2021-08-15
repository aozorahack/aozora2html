# encoding: utf-8
require 'test_helper'
require 'aozora2html'
require 'fileutils'
require 'tmpdir'

class Aozora2HtmlTest < Test::Unit::TestCase
  def setup
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    @parser = Aozora2Html.new(input, output)
  end

  def test_aozora2html_new
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "テスト\r\n")
      parser = Aozora2Html.new(input, output)
      begin
        assert_equal Aozora2Html, parser.class
      ensure
        parser.close
      end
    end
  end

  def test_line_number
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "a\r\nb\r\nc\r\n")
      parser = Aozora2Html.new(input, output)

      begin
        assert_equal 0, parser.line_number
        ch = parser.read_char
        assert_equal "a",ch
        assert_equal 1, parser.line_number
        ch = parser.read_char
        assert_equal "\r\n",ch
        assert_equal 1, parser.line_number
        ch = parser.read_char
        assert_equal "b",ch
        assert_equal 2, parser.line_number
        ch = parser.read_char
        assert_equal "\r\n",ch
        assert_equal 2, parser.line_number
        ch = parser.read_char
        assert_equal "c",ch
        assert_equal 3, parser.line_number
      ensure
        parser.close
      end
    end
  end

  def test_line_number2
    input = StringIO.new("a\r\nb\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    assert_equal 0, parser.line_number
    ch = parser.read_char
    assert_equal "a",ch
    assert_equal 1, parser.line_number
    ch = parser.read_char
    assert_equal "\r\n",ch
    assert_equal 1, parser.line_number
    ch = parser.read_char
    assert_equal "b",ch
    assert_equal 2, parser.line_number
    ch = parser.read_char
    assert_equal "\r\n",ch
    assert_equal 2, parser.line_number
    ch = parser.read_char
    assert_equal "c",ch
    assert_equal 3, parser.line_number
  end

  def test_read_line
    input = StringIO.new("ab\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    parsed = parser.read_line
    assert_equal "ab", parsed
  end

  def test_char_type
    assert_equal :kanji, @parser.char_type(Aozora2Html::Tag::EmbedGaiji.new(nil,"foo","1-2-3","name"))
    assert_equal :kanji, @parser.char_type(Aozora2Html::Tag::UnEmbedGaiji.new(nil,"foo"))
    assert_equal :hankaku, @parser.char_type(Aozora2Html::Tag::Accent.new(nil,123,"abc"))
    assert_equal :else, @parser.char_type(Aozora2Html::Tag::Okurigana.new(nil,"abc"))
    assert_equal :else, @parser.char_type(Aozora2Html::Tag::InlineKeigakomi.new(nil,"abc"))
    assert_equal :katakana, @parser.char_type(Aozora2Html::Tag::DakutenKatakana.new(nil,1,"abc"))

    assert_equal :hiragana, @parser.char_type("あ".encode("shift_jis"))
    assert_equal :hiragana, @parser.char_type("っ".encode("shift_jis"))
    assert_equal :katakana, @parser.char_type("ヴ".encode("shift_jis"))
    assert_equal :katakana, @parser.char_type("ー".encode("shift_jis"))
    assert_equal :zenkaku, @parser.char_type("Ａ".encode("shift_jis"))
    assert_equal :zenkaku, @parser.char_type("ｗ".encode("shift_jis"))
    assert_equal :hankaku, @parser.char_type("z".encode("shift_jis"))
    assert_equal :kanji, @parser.char_type("漢".encode("shift_jis"))
    assert_equal :hankaku_terminate, @parser.char_type("!".encode("shift_jis"))
    assert_equal :else, @parser.char_type("？".encode("shift_jis"))
    assert_equal :else, @parser.char_type("Å".encode("shift_jis"))
  end

  def test_read_char
    input = StringIO.new("／＼\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    char = parser.read_char
    assert_equal "／".encode("shift_jis"), char
    assert_equal Aozora2Html::KU, char
  end

  def test_illegal_char_check
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    begin
      parser.illegal_char_check("#", 123)
      outstr = out.string
      assert_equal "警告(123行目):1バイトの「#」が使われています\n", outstr.encode("utf-8")
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_sharp
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    begin
      parser.illegal_char_check("♯".encode("shift_jis"), 123)
      outstr = out.string
      assert_equal "警告(123行目):注記記号の誤用の可能性がある、「♯」が使われています\n", outstr.encode("utf-8")
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_notjis
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    begin
      parser.illegal_char_check("①".encode("cp932").force_encoding("shift_jis"), 123)
      outstr = out.string
      assert_equal "警告(123行目):JIS外字「①」が使われています\n", outstr.force_encoding("cp932").encode("utf-8")
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_ok
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    begin
      parser.illegal_char_check("あ".encode("shift_jis"), 123)
      outstr = output.string
      assert_equal "", outstr
    ensure
      $stdout = STDOUT
    end
  end

  def test_convert_japanese_number
    assert_equal "3字下げ",
                 Aozora2Html::Utils.convert_japanese_number("三字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "10字下げ",
                 Aozora2Html::Utils.convert_japanese_number("十字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "12字下げ",
                 Aozora2Html::Utils.convert_japanese_number("十二字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "20字下げ",
                 Aozora2Html::Utils.convert_japanese_number("二十字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "20字下げ",
                 Aozora2Html::Utils.convert_japanese_number("二〇字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "23字下げ",
                 Aozora2Html::Utils.convert_japanese_number("二十三字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "2字下げ",
                 Aozora2Html::Utils.convert_japanese_number("２字下げ".encode("shift_jis")).encode("utf-8")

  end

  def test_kuten2png
    assert_equal %q|<img src="../../../gaiji/1-84/1-84-77.png" alt="※(「てへん＋劣」、第3水準1-84-77)" class="gaiji" />|,
                 @parser.kuten2png("＃「てへん＋劣」、第3水準1-84-77".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|<img src="../../../gaiji/1-02/1-02-22.png" alt="※(二の字点、1-2-22)" class="gaiji" />|,
                 @parser.kuten2png("＃二の字点、1-2-22".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|<img src="../../../gaiji/1-06/1-06-57.png" alt="※(ファイナルシグマ、1-6-57)" class="gaiji" />|,
                 @parser.kuten2png("＃ファイナルシグマ、1-6-57".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|＃「口＋世」、151-23|,
                 @parser.kuten2png("＃「口＋世」、151-23".encode("shift_jis")).to_s.encode("utf-8")
  end

  def test_terpri?
    assert_equal true, @parser.terpri?([])
    assert_equal true, @parser.terpri?([""])
    assert_equal true, @parser.terpri?(["a"])
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser,"小".encode("shift_jis"),:normal)
    assert_equal false, @parser.terpri?([tag])
    assert_equal false, @parser.terpri?([tag,tag])
    assert_equal false, @parser.terpri?([tag,"",""])
    assert_equal false, @parser.terpri?(["",tag,""])
    assert_equal true, @parser.terpri?([tag,"a"])
    assert_equal true, @parser.terpri?(["a",tag])
  end

  def test_new_midashi_id
    midashi_id = @parser.new_midashi_id(1)
    assert_equal midashi_id + 1, @parser.new_midashi_id(1)
    assert_equal midashi_id + 2, @parser.new_midashi_id("小".encode("shift_jis"))
    assert_equal midashi_id + 12, @parser.new_midashi_id("中".encode("shift_jis"))
    assert_equal midashi_id + 112, @parser.new_midashi_id("大".encode("shift_jis"))
    assert_raise(Aozora2Html::Error) do
      @parser.new_midashi_id("？".encode("shift_jis"))
    end
  end

  def test_multiply
    bouki = @parser.multiply("x", 5)
    assert_equal "x&nbsp;x&nbsp;x&nbsp;x&nbsp;x", bouki
  end

  def test_apply_midashi
    midashi = @parser.apply_midashi("中見出し".encode("shift_jis"))
    assert_equal %Q|<h4 class="naka-midashi"><a class="midashi_anchor" id="midashi10">|, midashi.to_s
    midashi = @parser.apply_midashi("大見出し".encode("shift_jis"))
    assert_equal %Q|<h3 class="o-midashi"><a class="midashi_anchor" id="midashi110">|, midashi.to_s
  end

  def test_detect_command_mode
    command = "字下げ終わり".encode("shift_jis")
    assert_equal :jisage, @parser.detect_command_mode(command)
    command = "地付き終わり".encode("shift_jis")
    assert_equal :chitsuki, @parser.detect_command_mode(command)
    command = "中見出し終わり".encode("shift_jis")
    assert_equal :midashi, @parser.detect_command_mode(command)
    command = "ここで太字終わり".encode("shift_jis")
    assert_equal :futoji, @parser.detect_command_mode(command)
  end

  def test_tcy
    input = StringIO.new("［＃縦中横］（※［＃ローマ数字1、1-13-21］）\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.parse_body
      parser.general_output
    rescue Aozora2Html::Error => e
      message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):縦中横中に改行されました。改行をまたぐ要素にはブロック表記を用いてください. \r\n処理を停止します", message
    end
  end

  def test_ensure_close
    input = StringIO.new("［＃ここから５字下げ］\r\n底本： test\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.general_output
    rescue Aozora2Html::Error => e
      message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):字下げ中に本文が終了しました. \r\n処理を停止します", message
    end
  end

  def test_ending_check
    input = StringIO.new("本文\r\n\r\n底本：test\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    _message = nil
    begin
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
    rescue Aozora2Html::Error => e
      _message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      output.seek(0)
      out_text = output.read
      assert_equal "本文<br />\r\n<br />\r\n</div>\r\n<div class=\"bibliographical_information\">\r\n<hr />\r\n<br />\r\n", out_text
    end
  end

  def test_invalid_closing
    input = StringIO.new("［＃ここで太字終わり］\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.parse_body
    rescue Aozora2Html::Error => e
      message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):太字を閉じようとしましたが、太字中ではありません. \r\n処理を停止します", message
    end
  end

  def test_invalid_nest
    input = StringIO.new("［＃太字］［＃傍線］あ［＃太字終わり］\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
      parser.parse_body
    rescue Aozora2Html::Error => e
      message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):太字を終了しようとしましたが、傍線中です. \r\n処理を停止します", message
    end
  end

  def test_command_do
    input = StringIO.new("［＃ここから太字］\r\nテスト。\r\n［＃ここで太字終わり］\r\n".encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    _message = nil
    begin
      9.times do
        parser.parse_body
      end
    rescue Aozora2Html::Error => e
      _message = e.message.encode("utf-8")
    ensure
      $stdout = STDOUT
      output.seek(0)
      out_text = output.read
      assert_equal "<div class=\"futoji\">\r\nテスト。<br />\r\n</div>\r\n", out_text
    end
  end


  def teardown
  end
end
