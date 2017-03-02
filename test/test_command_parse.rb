# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class RubyParseTest < Test::Unit::TestCase
  def setup
  end

  def test_parse_command1
    src = "デボルド―※［＃濁点付き片仮名ワ、1-7-82］ルモオル\r\n"
    parsed = parse_text(src)
    expected = "デボルド—<img src=\"../../../gaiji/1-07/1-07-82.png\" alt=\"※(濁点付き片仮名ワ、1-7-82)\" class=\"gaiji\" />ルモオル<br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_command2
    src = "繁雑な日本の 〔e'tiquette〕 も、\r\n"
    parsed = parse_text(src)
    expected = %Q|繁雑な日本の <img src="../../../gaiji/1-09/1-09-63.png" alt="※(アキュートアクセント付きE小文字)" class="gaiji" />tiquette も、<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command3
    src = "〔Sito^t qu'on le touche il re'sonne.〕\r\n"
    parsed = parse_text(src)
    expected = %Q|Sit<img src="../../../gaiji/1-09/1-09-74.png" alt="※(サーカムフレックスアクセント付きO小文字)" class="gaiji" />t q<img src="../../../gaiji/1-09/1-09-79.png" alt="※(アキュートアクセント付きU小文字)" class="gaiji" />on le touche il r<img src="../../../gaiji/1-09/1-09-63.png" alt="※(アキュートアクセント付きE小文字)" class="gaiji" />sonne.<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command4
    src = "presqu'〔i^le〕\r\n"
    parsed = parse_text(src)
    expected = %Q|presqu'<img src="../../../gaiji/1-09/1-09-68.png" alt="※(サーカムフレックスアクセント付きI小文字)" class="gaiji" />le<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command5
    src = "［二十歳の 〔E'tude〕］\r\n"
    parsed = parse_text(src)
    expected = %Q|［二十歳の <img src="../../../gaiji/1-09/1-09-32.png" alt="※(アキュートアクセント付きE)" class="gaiji" />tude］<br />\r\n|
    assert_equal expected, parsed
  end

  def parse_text(input_text)
    input = StringIO.new(input_text.encode("shift_jis"))
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    parser.instance_eval{@section=:tail}
    catch(:terminate) do
      loop do
        parser.parse
      end
    end

    output.string.encode("utf-8")
  end
end
