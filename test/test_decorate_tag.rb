# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class DecorateTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_decorate_new
    tag = Aozora2Html::Tag::Decorate.new(@parser,"aa",1,:dai)
    assert_equal Aozora2Html::Tag::Decorate, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Decorate.new(@parser,"テスト".encode("shift_jis"),"foo","span")
    assert_equal "<span class=\"foo\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
