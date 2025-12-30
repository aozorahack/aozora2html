# frozen_string_literal: true

require_relative 'test_helper'
require 'aozora2html'

class Aozora2HtmlAccentParserTest < Test::Unit::TestCase
  def test_new
    str = "〔e'tiquette〕\r\n"
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora2Html::AccentParser.new(stream, '〕', {}, [], gaiji_dir: 'g_dir/').process
    expected = '〔<img src="g_dir/1-09/1-09-63.png" alt="※(アキュートアクセント付きE小文字)" class="gaiji" />tiquette'
    assert_equal expected, parsed.to_s
  end

  def test_invalid
    str = "〔e'tiquette\r\n"
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    $stdout = StringIO.new
    begin
      _parsed = Aozora2Html::AccentParser.new(stream, '〕', {}, [], gaiji_dir: 'g_dir/').process
      out_str = $stdout.string
      assert_equal "警告(1行目):アクセント分解の亀甲括弧の始めと終わりが、行中で揃っていません\n", out_str
    ensure
      $stdout = STDOUT
    end
  end

  def test_use_jisx0213_class
    Aozora2Html::Tag::Accent.use_jisx0213 = true
    str = "〔e'tiquette〕\r\n"
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora2Html::AccentParser.new(stream, '〕', {}, [], gaiji_dir: 'g_dir/').process
    expected = '〔&#x00E9;tiquette'
    assert_equal expected, parsed.to_s
  end

  def test_use_jisx0213
    str = "〔e'tiquette〕\r\n"
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora2Html::AccentParser.new(stream, '〕', {}, [], gaiji_dir: 'g_dir/', use_jisx0213: true).process
    expected = '〔&#x00E9;tiquette'
    assert_equal expected, parsed.to_s
  end

  def teardown
    Aozora2Html::Tag::Accent.use_jisx0213 = nil
  end
end
