require 'test_helper'
require 'aozora2html'

class FontSizeTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_font_size_new
    tag = Aozora2Html::Tag::FontSize.new(@parser,1,:dai)
    assert_equal Aozora2Html::Tag::FontSize, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::FontSize.new(@parser,1,:dai)
    assert_equal "<div class=\"dai1\" style=\"font-size: large;\">", tag.to_s.encode("utf-8")
  end

  def test_to_s2
    tag = Aozora2Html::Tag::FontSize.new(@parser,2,:dai)
    assert_equal "<div class=\"dai2\" style=\"font-size: x-large;\">", tag.to_s.encode("utf-8")
  end

  def test_to_s3
    tag = Aozora2Html::Tag::FontSize.new(@parser,3,:sho)
    assert_equal "<div class=\"sho3\" style=\"font-size: xx-small;\">", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
