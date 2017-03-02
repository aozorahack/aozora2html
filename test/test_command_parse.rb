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

  def test_parse_command6
    src = "責［＃「責」に白ゴマ傍点］空文庫\r\n"
    parsed = parse_text(src)
    expected = %Q|<em class="white_sesame_dot">責</em>空文庫<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command7
    src = "［＃丸傍点］青空文庫で読書しよう［＃丸傍点終わり］。\r\n"
    parsed = parse_text(src)
    expected = %Q|<em class="black_circle">青空文庫で読書しよう</em>。<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command8
    src = "この形は傍線［＃「傍線」に傍線］と書いてください。\r\n"
    parsed = parse_text(src)
    expected = %Q|この形は<em class="underline_solid">傍線</em>と書いてください。<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command9
    src = "［＃左に鎖線］青空文庫で読書しよう［＃左に鎖線終わり］。\r\n"
    parsed = parse_text(src)
    expected = %Q|<em class="overline_dotted">青空文庫で読書しよう</em>。<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command10
    src = "「クリス、宇宙航行委員会が選考［＃「選考」は太字］するんだ。きみは志願できない。待つ［＃「待つ」は太字］んだ」\r\n"
    parsed = parse_text(src)
    expected = %Q|「クリス、宇宙航行委員会が<span class="futoji">選考</span>するんだ。きみは志願できない。<span class="futoji">待つ</span>んだ」<br />\r\n|
    assert_equal expected, parsed
  end

  def test_parse_command11
    src = "Which, teaching us, hath this exordium: Nothing from nothing ever yet was born.［＃「Nothing from nothing ever yet was born.」は斜体］\r\n"
    parsed = parse_text(src)
    expected = %Q|Which, teaching us, hath this exordium: <span class="shatai">Nothing from nothing ever yet was born.</span><br />\r\n|
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
