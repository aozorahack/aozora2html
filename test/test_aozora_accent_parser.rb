require 'test_helper'
require 'aozora2html'

class Aozora2HtmlTest < Test::Unit::TestCase
  def setup
  end

  def test_new
    str = "〔e'tiquette〕\r\n".encode("shift_jis")
    strio = StringIO.new(str)
    stream = Jstream.new(strio)
    parsed = Aozora_accent_parser.new(stream,"〕".encode("shift_jis"),{},[]).process
    expected = "〔<img src=\"../../../gaiji/1-09/1-09-63.png\" alt=\"※(アキュートアクセント付きE小文字)\" class=\"gaiji\" />tiquette"
    assert_equal expected, parsed.to_s.encode("utf-8")
  end

  def teardown
  end
end
