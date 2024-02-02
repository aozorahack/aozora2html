# frozen_string_literal: true

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
      input = File.join(dir, 'dummy.txt')
      output = File.join(dir, 'dummy2.txt')
      File.binwrite(input, "テスト\r\n")
      parser = Aozora2Html.new(input, output)
      begin
        assert_equal Aozora2Html, parser.class
      ensure
        parser.__send__(:close)
      end
    end
  end

  def test_line_number
    Dir.mktmpdir do |dir|
      input = File.join(dir, 'dummy.txt')
      output = File.join(dir, 'dummy2.txt')
      File.binwrite(input, "a\r\nb\r\nc\r\n")
      parser = Aozora2Html.new(input, output)

      begin
        assert_equal 0, parser.line_number
        ch = parser.__send__(:read_char)
        assert_equal 'a', ch
        assert_equal 1, parser.line_number
        ch = parser.__send__(:read_char)
        assert_equal "\r\n", ch
        assert_equal 1, parser.line_number
        ch = parser.__send__(:read_char)
        assert_equal 'b', ch
        assert_equal 2, parser.line_number
        ch = parser.__send__(:read_char)
        assert_equal "\r\n", ch
        assert_equal 2, parser.line_number
        ch = parser.__send__(:read_char)
        assert_equal 'c', ch
        assert_equal 3, parser.line_number
      ensure
        parser.__send__(:close)
      end
    end
  end

  def test_line_number2
    input = StringIO.new("a\r\nb\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    assert_equal 0, parser.line_number
    ch = parser.__send__(:read_char)
    assert_equal 'a', ch
    assert_equal 1, parser.line_number
    ch = parser.__send__(:read_char)
    assert_equal "\r\n", ch
    assert_equal 1, parser.line_number
    ch = parser.__send__(:read_char)
    assert_equal 'b', ch
    assert_equal 2, parser.line_number
    ch = parser.__send__(:read_char)
    assert_equal "\r\n", ch
    assert_equal 2, parser.line_number
    ch = parser.__send__(:read_char)
    assert_equal 'c', ch
    assert_equal 3, parser.line_number
  end

  def test_read_line
    input = StringIO.new("ab\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    parsed = parser.__send__(:read_line)
    assert_equal 'ab', parsed
  end

  using Aozora2Html::StringRefinements

  def test_char_type
    assert_equal :kanji, Aozora2Html::Tag::EmbedGaiji.new(nil, 'foo', '1-2-3', 'name', gaiji_dir: nil).char_type
    assert_equal :kanji, Aozora2Html::Tag::UnEmbedGaiji.new(nil, 'foo').char_type
    assert_equal :hankaku, Aozora2Html::Tag::Accent.new(nil, 123, 'abc', gaiji_dir: nil).char_type
    assert_equal :else, Aozora2Html::Tag::Okurigana.new(nil, 'abc').char_type
    assert_equal :else, Aozora2Html::Tag::InlineKeigakomi.new(nil, 'abc').char_type

    assert_equal :hiragana, 'あ'.to_sjis.char_type
    assert_equal :hiragana, 'っ'.to_sjis.char_type
    assert_equal :katakana, 'ヴ'.to_sjis.char_type
    assert_equal :katakana, 'ー'.to_sjis.char_type
    assert_equal :zenkaku, 'Ａ'.to_sjis.char_type
    assert_equal :zenkaku, 'ｗ'.to_sjis.char_type
    assert_equal :hankaku, 'z'.to_sjis.char_type
    assert_equal :kanji, '漢'.to_sjis.char_type
    assert_equal :hankaku_terminate, '!'.to_sjis.char_type
    assert_equal :else, '？'.to_sjis.char_type
    assert_equal :else, 'Å'.to_sjis.char_type
  end

  def test_read_char
    input = StringIO.new("／＼\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    char = parser.__send__(:read_char)
    assert_equal '／'.to_sjis, char
    assert_equal Aozora2Html::KU, char
  end

  def test_illegal_char_check
    out = StringIO.new
    $stdout = out
    begin
      Aozora2Html::Utils.illegal_char_check('#', 123)
      outstr = out.string
      assert_equal "警告(123行目):1バイトの「#」が使われています\n", outstr.to_utf8
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_sharp
    out = StringIO.new
    $stdout = out
    begin
      Aozora2Html::Utils.illegal_char_check('♯'.to_sjis, 123)
      outstr = out.string
      assert_equal "警告(123行目):注記記号の誤用の可能性がある、「♯」が使われています\n", outstr.to_utf8
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_notjis
    out = StringIO.new
    $stdout = out
    begin
      Aozora2Html::Utils.illegal_char_check('①'.encode('cp932').force_encoding('shift_jis'), 123)
      outstr = out.string
      assert_equal "警告(123行目):JIS外字「①」が使われています\n", outstr.force_encoding('cp932').to_utf8
    ensure
      $stdout = STDOUT
    end
  end

  def test_illegal_char_check_ok
    out = StringIO.new
    $stdout = out
    begin
      Aozora2Html::Utils.illegal_char_check('あ'.to_sjis, 123)
      outstr = out.string
      assert_equal '', outstr
    ensure
      $stdout = STDOUT
    end
  end

  def test_convert_japanese_number
    assert_equal '3字下げ',
                 Aozora2Html::Utils.convert_japanese_number('三字下げ'.to_sjis).to_utf8
    assert_equal '10字下げ',
                 Aozora2Html::Utils.convert_japanese_number('十字下げ'.to_sjis).to_utf8
    assert_equal '12字下げ',
                 Aozora2Html::Utils.convert_japanese_number('十二字下げ'.to_sjis).to_utf8
    assert_equal '20字下げ',
                 Aozora2Html::Utils.convert_japanese_number('二十字下げ'.to_sjis).to_utf8
    assert_equal '20字下げ',
                 Aozora2Html::Utils.convert_japanese_number('二〇字下げ'.to_sjis).to_utf8
    assert_equal '23字下げ',
                 Aozora2Html::Utils.convert_japanese_number('二十三字下げ'.to_sjis).to_utf8
    assert_equal '2字下げ',
                 Aozora2Html::Utils.convert_japanese_number('２字下げ'.to_sjis).to_utf8
  end

  def test_kuten2png
    assert_equal %q|<img src="../../../gaiji/1-84/1-84-77.png" alt="※(「てへん＋劣」、第3水準1-84-77)" class="gaiji" />|,
                 @parser.kuten2png('＃「てへん＋劣」、第3水準1-84-77'.to_sjis).to_s.to_utf8
    assert_equal %q|<img src="../../../gaiji/1-02/1-02-22.png" alt="※(二の字点、1-2-22)" class="gaiji" />|,
                 @parser.kuten2png('＃二の字点、1-2-22'.to_sjis).to_s.to_utf8
    assert_equal %q|<img src="../../../gaiji/1-06/1-06-57.png" alt="※(ファイナルシグマ、1-6-57)" class="gaiji" />|,
                 @parser.kuten2png('＃ファイナルシグマ、1-6-57'.to_sjis).to_s.to_utf8
    assert_equal %q(＃「口＋世」、151-23),
                 @parser.kuten2png('＃「口＋世」、151-23'.to_sjis).to_s.to_utf8
  end

  def test_terpri?
    assert_equal true, Aozora2Html::TextBuffer.new.terpri?
    assert_equal true, Aozora2Html::TextBuffer.new(['']).terpri?
    assert_equal true, Aozora2Html::TextBuffer.new(['a']).terpri?
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser, '小'.to_sjis, :normal)
    assert_equal false, Aozora2Html::TextBuffer.new([tag]).terpri?
    assert_equal false, Aozora2Html::TextBuffer.new([tag, tag]).terpri?
    assert_equal false, Aozora2Html::TextBuffer.new([tag, '', '']).terpri?
    assert_equal false, Aozora2Html::TextBuffer.new(['', tag, '']).terpri?
    assert_equal true, Aozora2Html::TextBuffer.new([tag, 'a']).terpri?
    assert_equal true, Aozora2Html::TextBuffer.new(['a', tag]).terpri?
  end

  def test_new_midashi_id
    midashi_id = @parser.new_midashi_id(1)
    assert_equal midashi_id + 1, @parser.new_midashi_id(1)
    assert_equal midashi_id + 2, @parser.new_midashi_id('小'.to_sjis)
    assert_equal midashi_id + 12, @parser.new_midashi_id('中'.to_sjis)
    assert_equal midashi_id + 112, @parser.new_midashi_id('大'.to_sjis)
    assert_raise(Aozora2Html::Error) do
      @parser.new_midashi_id('？'.to_sjis)
    end
  end

  def test_multiply
    bouki = @parser.__send__(:multiply, 'x', 5)
    assert_equal 'x&nbsp;x&nbsp;x&nbsp;x&nbsp;x', bouki
  end

  def test_apply_midashi
    midashi = @parser.__send__(:apply_midashi, '中見出し'.to_sjis)
    assert_equal %Q(<h4 class="naka-midashi"><a class="midashi_anchor" id="midashi10">), midashi.to_s
    midashi = @parser.__send__(:apply_midashi, '大見出し'.to_sjis)
    assert_equal %Q(<h3 class="o-midashi"><a class="midashi_anchor" id="midashi110">), midashi.to_s
  end

  def test_detect_command_mode
    command = '字下げ終わり'.to_sjis
    assert_equal :jisage, @parser.detect_command_mode(command)
    command = '地付き終わり'.to_sjis
    assert_equal :chitsuki, @parser.detect_command_mode(command)
    command = '中見出し終わり'.to_sjis
    assert_equal :midashi, @parser.detect_command_mode(command)
    command = 'ここで太字終わり'.to_sjis
    assert_equal :futoji, @parser.detect_command_mode(command)
  end

  def test_tcy
    input = StringIO.new("［＃縦中横］（※［＃ローマ数字1、1-13-21］）\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.__send__(:parse_body)
      parser.__send__(:general_output)
    rescue Aozora2Html::Error => e
      message = e.message.to_utf8
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):縦中横中に改行されました。改行をまたぐ要素にはブロック表記を用いてください. \r\n処理を停止します", message
    end
  end

  def test_ensure_close
    input = StringIO.new("［＃ここから５字下げ］\r\n底本： test\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:general_output)
    rescue Aozora2Html::Error => e
      message = e.message.to_utf8
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):字下げ中に本文が終了しました. \r\n処理を停止します", message
    end
  end

  def test_ending_check
    input = StringIO.new("本文\r\n\r\n底本：test\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    _message = nil
    begin
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
    rescue Aozora2Html::Error => e
      _message = e.message.to_utf8
    ensure
      $stdout = STDOUT
      output.seek(0)
      out_text = output.read
      assert_equal "本文<br />\r\n<br />\r\n</div>\r\n<div class=\"bibliographical_information\">\r\n<hr />\r\n<br />\r\n", out_text
    end
  end

  def test_invalid_closing
    input = StringIO.new("［＃ここで太字終わり］\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.__send__(:parse_body)
    rescue Aozora2Html::Error => e
      message = e.message.to_utf8
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):太字を閉じようとしましたが、太字中ではありません. \r\n処理を停止します", message
    end
  end

  def test_invalid_nest
    input = StringIO.new("［＃太字］［＃傍線］あ［＃太字終わり］\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    message = nil
    begin
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
      parser.__send__(:parse_body)
    rescue Aozora2Html::Error => e
      message = e.message.to_utf8
    ensure
      $stdout = STDOUT
      assert_equal "エラー(0行目):太字を終了しようとしましたが、傍線中です. \r\n処理を停止します", message
    end
  end

  def test_command_do
    input = StringIO.new("［＃ここから太字］\r\nテスト。\r\n［＃ここで太字終わり］\r\n".to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    out = StringIO.new
    $stdout = out
    _message = nil
    begin
      9.times do
        parser.__send__(:parse_body)
      end
    rescue Aozora2Html::Error => e
      _message = e.message.to_utf8
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
