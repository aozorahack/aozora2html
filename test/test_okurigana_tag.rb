require 'test_helper'
require 'aozora2xhtml'

class OkuriganaTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_okurigana_new
    tag = Okurigana_tag.new(@parser,"aaa")
    assert_equal Okurigana_tag, tag.class
    assert_equal true, tag.kind_of?(Inline_tag)
  end

  def test_to_s
    tag = Okurigana_tag.new(@parser,"テスト".encode("shift_jis"))
    assert_equal "<sup class=\"okurigana\">テスト</sup>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
