# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class DecorateTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_decorate_new
    tag = Decorate_tag.new(@parser,"aa",1,:dai)
    assert_equal Decorate_tag, tag.class
    assert_equal true, tag.kind_of?(Inline_tag)
  end

  def test_to_s
    tag = Decorate_tag.new(@parser,"テスト".encode("shift_jis"),"foo","span")
    assert_equal "<span class=\"foo\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
