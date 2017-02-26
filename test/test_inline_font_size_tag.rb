# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class InlineFontSizeTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_font_size_new
    tag = Aozora2Html::Tag::InlineFontSize.new(@parser,"aa",1,:dai)
    assert_equal Aozora2Html::Tag::InlineFontSize, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::InlineFontSize.new(@parser,"テスト".encode("shift_jis"),1,:dai)
    assert_equal "<span class=\"dai1\" style=\"font-size: large;\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def test_to_s2
    tag = Aozora2Html::Tag::InlineFontSize.new(@parser,"テスト".encode("shift_jis"),2,:sho)
    assert_equal "<span class=\"sho2\" style=\"font-size: x-small;\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def test_to_s3
    tag = Aozora2Html::Tag::InlineFontSize.new(@parser,"テスト".encode("shift_jis"),3,:sho)
    assert_equal "<span class=\"sho3\" style=\"font-size: xx-small;\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
