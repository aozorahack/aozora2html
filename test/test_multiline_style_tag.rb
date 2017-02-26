require 'test_helper'
require 'aozora2html'

class MultilineStyleTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_multiline_style_new
    tag = Aozora2Html::Tag::MultilineStyle.new(@parser,"style1")
    assert_equal Aozora2Html::Tag::MultilineStyle, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::MultilineStyle.new(@parser,"s1")
    assert_equal "<div class=\"s1\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
