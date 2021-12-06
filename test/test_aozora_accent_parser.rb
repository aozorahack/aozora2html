# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class Aozora2HtmlAccentParserTest < Test::Unit::TestCase
  def setup
  end

  def test_new
    str = "〔e'tiquette〕\r\n".encode('shift_jis')
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora2Html::AccentParser.new(stream, '〕'.encode('shift_jis'), {}, [], gaiji_dir: 'g_dir/').process
    expected = '〔<img src="g_dir/1-09/1-09-63.png" alt="※(アキュートアクセント付きE小文字)" class="gaiji" />tiquette'
    assert_equal expected, parsed.to_s.encode('utf-8')
  end

  def test_use_jisx0213
    Aozora2Html::Tag::Accent.use_jisx0213 = true
    str = "〔e'tiquette〕\r\n".encode('shift_jis')
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora2Html::AccentParser.new(stream, '〕'.encode('shift_jis'), {}, [], gaiji_dir: 'g_dir/').process
    expected = '〔&#x00E9;tiquette'
    assert_equal expected, parsed.to_s.encode('utf-8')
  end

  def teardown
    Aozora2Html::Tag::Accent.use_jisx0213 = nil
  end
end
