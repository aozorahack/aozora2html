# frozen_string_literal: true

require_relative 'test_helper'
require 'aozora2html'

class RubyParseTest < Test::Unit::TestCase
  def setup
  end

  def test_parse_ruby1
    src = "青空文庫《あおぞらぶんこ》\r\n"
    parsed = parse_text(src)
    expected = "<ruby><rb>青空文庫</rb><rp>（</rp><rt>あおぞらぶんこ</rt><rp>）</rp></ruby><br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby1b
    src = "身装《みなり》\r\n"
    parsed = parse_text(src)
    expected = "<ruby><rb>身装</rb><rp>（</rp><rt>みなり</rt><rp>）</rp></ruby><br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby2
    src = "霧の｜ロンドン警視庁《スコットランドヤード》\r\n"
    parsed = parse_text(src)
    expected = "霧の<ruby><rb>ロンドン警視庁</rb><rp>（</rp><rt>スコットランドヤード</rt><rp>）</rp></ruby><br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby2b
    src = "いかにも最｜猛者《もさ》のように\r\n"
    parsed = parse_text(src)
    expected = "いかにも最<ruby><rb>猛者</rb><rp>（</rp><rt>もさ</rt><rp>）</rp></ruby>のように<br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby3
    src = "〆切《しめきり》を逃れるために、市ヶ谷《いちがや》から転々《てんてん》と、居を移した。\r\n"
    parsed = parse_text(src)
    expected = "<ruby><rb>〆切</rb><rp>（</rp><rt>しめきり</rt><rp>）</rp></ruby>を逃れるために、<ruby><rb>市ヶ谷</rb><rp>（</rp><rt>いちがや</rt><rp>）</rp></ruby>から<ruby><rb>転々</rb><rp>（</rp><rt>てんてん</rt><rp>）</rp></ruby>と、居を移した。<br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby4
    src = "水鉢を置いた※［＃「木＋靈」、第3水準1-86-29］子窓《れんじまど》の下には\r\n"
    parsed = parse_text(src)
    expected = "水鉢を置いた<ruby><rb><img src=\"../../../gaiji/1-86/1-86-29.png\" alt=\"※(「木＋靈」、第3水準1-86-29)\" class=\"gaiji\" />子窓</rb><rp>（</rp><rt>れんじまど</rt><rp>）</rp></ruby>の下には<br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby5
    src = "それが彼の 〔E'tude〕《エチュード》 だった。\r\n"
    parsed = parse_text(src)
    expected = "それが彼の <ruby><rb><img src=\"../../../gaiji/1-09/1-09-32.png\" alt=\"※(アキュートアクセント付きE)\" class=\"gaiji\" />tude</rb><rp>（</rp><rt>エチュード</rt><rp>）</rp></ruby> だった。<br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby6
    src = "青空文庫［＃「青空文庫」の左に「あおぞらぶんこ」のルビ］\r\n"
    parsed = parse_text(src)
    expected = "青空文庫<span class=\"notes\">［＃「青空文庫」の左に「あおぞらぶんこ」のルビ］</span><br />\r\n"
    assert_equal expected, parsed
  end

  def test_parse_ruby7
    src = "青空文庫《あおぞらぶんこ》［＃「青空文庫」の左に「aozora bunko」のルビ］\r\n"
    parsed = parse_text(src)
    expected = %Q(<ruby><rb>青空文庫</rb><rp>（</rp><rt>あおぞらぶんこ</rt><rp>）</rp></ruby><span class="notes">［＃「青空文庫」の左に「aozora bunko」のルビ］</span><br />\r\n)
    assert_equal expected, parsed
  end

  def test_parse_ruby8
    src = "大空文庫［＃「大空文庫」に「ママ」の注記］\r\n"
    parsed = parse_text(src)
    expected = %Q(<ruby><rb>大空文庫</rb><rp>（</rp><rt>ママ</rt><rp>）</rp></ruby><br />\r\n)
    assert_equal expected, parsed
  end

  def test_parse_ruby9
    src = "大空文庫［＃「大空文庫」の左に「ママ」の注記］\r\n"
    parsed = parse_text(src)
    expected = %Q(大空文庫<span class="notes">［＃「大空文庫」の左に「ママ」の注記］</span><br />\r\n)
    assert_equal expected, parsed
  end

  def test_parse_ruby10
    src = "大空文庫《あおぞらぶんこ》［＃「大空文庫」の左に「ママ」の注記］\r\n"
    parsed = parse_text(src)
    expected = %Q(<ruby><rb>大空文庫</rb><rp>（</rp><rt>あおぞらぶんこ</rt><rp>）</rp></ruby><span class="notes">［＃「大空文庫」の左に「ママ」の注記］</span><br />\r\n)
    assert_equal expected, parsed
  end

  using Aozora2Html::StringRefinements

  def test_parse_ruby11
    src = "大空文庫《あおぞらぶんこ》［＃「大空文庫」に「ママ」の注記］\r\n"
    assert_raise(Aozora2Html::Error.new('同じ箇所に2つのルビはつけられません')) do
      _parsed = parse_text(src)
    end
  end

  def test_parse_ruby12
    src = "［＃注記付き］名※［＃二の字点、1-2-22］［＃「（銘々）」の注記付き終わり］\r\n"
    parsed = parse_text(src)
    expected = %Q|<ruby><rb>名<img src="../../../gaiji/1-02/1-02-22.png" alt="※(二の字点、1-2-22)" class="gaiji" /></rb><rp>（</rp><rt>（銘々）</rt><rp>）</rp></ruby><br />\r\n|
    assert_equal expected, parsed
  end

  def parse_text(input_text)
    input = StringIO.new(input_text.to_sjis)
    output = StringIO.new
    parser = Aozora2Html.new(input, output)
    parser.instance_eval { @section = :tail }
    catch(:terminate) do
      loop do
        parser.__send__(:parse)
      end
    end

    output.string.to_utf8
  end
end
