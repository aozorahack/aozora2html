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

  def test_read_line
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
      parser = Aozora2Html.new(input, output)
      begin
        parsed = parser.read_line
        assert_equal "ab", parsed
      ensure
        parser.close
      end
    end
  end

  def test_char_type
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
      parser = Aozora2Html.new(input, output)

      begin
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
        assert_equal :zenkaku, parser.char_type("ｗ".encode("shift_jis"))
        assert_equal :hankaku, parser.char_type("z".encode("shift_jis"))
        assert_equal :kanji, parser.char_type("漢".encode("shift_jis"))
        assert_equal :hankaku_terminate, parser.char_type("!".encode("shift_jis"))
        assert_equal :else, parser.char_type("？".encode("shift_jis"))
      ensure
        parser.close
      end
    end
  end

  def test_read_char
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "／＼\r\n".encode("shift_jis"))
      parser = Aozora2Html.new(input, output)
      begin
        char = parser.read_char
        assert_equal "／".encode("shift_jis"), char
        assert_equal Aozora2Html.class_eval("@@ku"), char
      ensure
        parser.close
      end
    end
  end

  def test_illegal_char_check
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
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
  end

  def test_illegal_char_check_sharp
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
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
  end

  def test_illegal_char_check_notjis
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
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
  end

  def test_illegal_char_check_ok
    Dir.mktmpdir do |dir|
      input = File.join(dir,'dummy.txt')
      output = File.join(dir,'dummy2.txt')
      File.binwrite(input, "ab\r\nc\r\n")
      parser = Aozora2Html.new(input, output)
      out = StringIO.new
      $stdout = out
      begin
        parser.illegal_char_check("あ".encode("shift_jis"), 123)
        outstr = out.string
        assert_equal "", outstr
      ensure
        $stdout = STDOUT
      end
    end
  end

  def teardown
  end
end
