# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class OkuriganaTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_okurigana_new
    tag = Aozora2Html::Tag::Okurigana.new(@parser,"aaa")
    assert_equal Aozora2Html::Tag::Okurigana, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Okurigana.new(@parser,"テスト".encode("shift_jis"))
    assert_equal "<sup class=\"okurigana\">テスト</sup>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
