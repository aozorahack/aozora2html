# encoding: utf-8
require 'test_helper'
require 'aozora2html'
require 'fileutils'
require 'tmpdir'

class Aozora2HtmlTest < Test::Unit::TestCase
  def setup
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

  def test_scount
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "a\r\nb\r\nc\r\n")
      parser = Aozora2Html.new(input, output)

      begin
        assert_equal 0, parser.scount
        ch = parser.read_char
        assert_equal "a",ch
        assert_equal 1, parser.scount
        ch = parser.read_char
        assert_equal "\r\n",ch
        assert_equal 1, parser.scount
        ch = parser.read_char
        assert_equal "b",ch
        assert_equal 2, parser.scount
        ch = parser.read_char
        assert_equal "\r\n",ch
        assert_equal 2, parser.scount
        ch = parser.read_char
        assert_equal "c",ch
        assert_equal 3, parser.scount
      ensure
        parser.close
      end
    end
  end

  def test_scount_2
    input = StringIO.new("a\r\nb\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    assert_equal 0, parser.scount
    ch = parser.read_char
    assert_equal "a",ch
    assert_equal 1, parser.scount
    ch = parser.read_char
    assert_equal "\r\n",ch
    assert_equal 1, parser.scount
    ch = parser.read_char
    assert_equal "b",ch
    assert_equal 2, parser.scount
    ch = parser.read_char
    assert_equal "\r\n",ch
    assert_equal 2, parser.scount
    ch = parser.read_char
    assert_equal "c",ch
    assert_equal 3, parser.scount
  end

  def test_read_line
    input = StringIO.new("ab\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    parsed = parser.read_line
    assert_equal "ab", parsed
  end

  def test_char_type
    input = StringIO.new("ab\r\nc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)

    assert_equal :kanji, parser.char_type(Aozora2Html::Tag::EmbedGaiji.new(nil,"foo","1-2-3","name"))
    assert_equal :kanji, parser.char_type(Aozora2Html::Tag::UnEmbedGaiji.new(nil,"foo"))
    assert_equal :hankaku, parser.char_type(Aozora2Html::Tag::Accent.new(nil,123,"abc"))
    assert_equal :else, parser.char_type(Aozora2Html::Tag::Okurigana.new(nil,"abc"))
    assert_equal :else, parser.char_type(Aozora2Html::Tag::InlineKeigakomi.new(nil,"abc"))
    assert_equal :katakana, parser.char_type(Aozora2Html::Tag::DakutenKatakana.new(nil,1,"abc"))

    assert_equal :hiragana, parser.char_type("あ".encode("shift_jis"))
    assert_equal :hiragana, parser.char_type("っ".encode("shift_jis"))
    assert_equal :katakana, parser.char_type("ヴ".encode("shift_jis"))
    assert_equal :katakana, parser.char_type("ー".encode("shift_jis"))
    assert_equal :zenkaku, parser.char_type("Ａ".encode("shift_jis"))
    assert_equal :zenkaku, parser.char_type("ｗ".encode("shift_jis"))
    assert_equal :hankaku, parser.char_type("z".encode("shift_jis"))
    assert_equal :kanji, parser.char_type("漢".encode("shift_jis"))
    assert_equal :hankaku_terminate, parser.char_type("!".encode("shift_jis"))
    assert_equal :else, parser.char_type("？".encode("shift_jis"))
    assert_equal :else, parser.char_type("Å".encode("shift_jis"))
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
      assert_equal "警告(123行目):1バイトの「#」が使われています\n", outstr
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
      assert_equal "警告(123行目):注記記号の誤用の可能性がある、「♯」が使われています\n", outstr
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
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)

    assert_equal "3字下げ",
                 parser.convert_japanese_number("三字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "10字下げ",
                 parser.convert_japanese_number("十字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "12字下げ",
                 parser.convert_japanese_number("十二字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "20字下げ",
                 parser.convert_japanese_number("二十字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "20字下げ",
                 parser.convert_japanese_number("二〇字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "23字下げ",
                 parser.convert_japanese_number("二十三字下げ".encode("shift_jis")).encode("utf-8")
    assert_equal "2字下げ",
                 parser.convert_japanese_number("２字下げ".encode("shift_jis")).encode("utf-8")

  end

  def test_kuten2png
    input = StringIO.new("abc\r\n")
    output = StringIO.new
    parser = Aozora2Html.new(input, output)

    assert_equal %q|<img src="../../../gaiji/1-84/1-84-77.png" alt="※(「てへん＋劣」、第3水準1-84-77)" class="gaiji" />|,
                 parser.kuten2png("＃「てへん＋劣」、第3水準1-84-77".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|<img src="../../../gaiji/1-02/1-02-22.png" alt="※(二の字点、1-2-22)" class="gaiji" />|,
                 parser.kuten2png("＃二の字点、1-2-22".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|<img src="../../../gaiji/1-06/1-06-57.png" alt="※(ファイナルシグマ、1-6-57)" class="gaiji" />|,
                 parser.kuten2png("＃ファイナルシグマ、1-6-57".encode("shift_jis")).to_s.encode("utf-8")
    assert_equal %q|＃「口＋世」、151-23|,
                 parser.kuten2png("＃「口＋世」、151-23".encode("shift_jis")).to_s.encode("utf-8")
  end


  def teardown
  end
end
