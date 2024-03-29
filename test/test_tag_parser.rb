# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'
require 'fileutils'
require 'tmpdir'

class TagParserTest < Test::Unit::TestCase
  def setup
    @jisx0213 = Aozora2Html::Tag::EmbedGaiji.use_jisx0213
  end

  using Aozora2Html::StringRefinements

  def test_parse_katakana
    str = "テスト！あいうえお\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '！'.to_sjis, {}, [], gaiji_dir: nil).process
    expected = 'テスト'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_bouten
    str = "腹がへっても［＃「腹がへっても」に傍点］、ひもじゅうない［＃「ひもじゅうない」に傍点］とかぶりを振っている…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: nil).process
    expected = '<em class="sesame_dot">腹がへっても</em>、<em class="sesame_dot">ひもじゅうない</em>とかぶりを振っている'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji
    str = "※［＃「てへん＋劣」、第3水準1-84-77］…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/').process
    expected = '<img src="g_dir/1-84/1-84-77.png" alt="※(「てへん＋劣」、第3水準1-84-77)" class="gaiji" />'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji_a
    str = "※［＃「口＋世」、ページ数-行数］…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/').process
    expected = '※<span class="notes">［＃「口＋世」、ページ数-行数］</span>'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji_b
    str = "※［＃二の字点、1-2-22］…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/').process
    expected = '<img src="g_dir/1-02/1-02-22.png" alt="※(二の字点、1-2-22)" class="gaiji" />'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji_kaeri
    str = "自［＃二］女王國［＃一］東度［＃レ］海千餘里。…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/').process
    expected = '自<sub class="kaeriten">二</sub>女王國<sub class="kaeriten">一</sub>東度<sub class="kaeriten">レ</sub>海千餘里。'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji_jisx0213_class
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = true
    str = "※［＃「てへん＋劣」、第3水準1-84-77］…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/').process
    expected = '&#x6318;'
    assert_equal expected, command.to_s.to_utf8
  end

  def test_parse_gaiji_jisx0213
    str = "※［＃「てへん＋劣」、第3水準1-84-77］…\r\n".to_sjis
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    command, _raw = Aozora2Html::TagParser.new(stream, '…'.to_sjis, {}, [], gaiji_dir: 'g_dir/', use_jisx0213: true).process
    expected = '&#x6318;'
    assert_equal expected, command.to_s.to_utf8
  end

  def teardown
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = @jisx0213
  end
end
