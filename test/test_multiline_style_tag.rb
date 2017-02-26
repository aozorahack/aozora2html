require 'test_helper'
require 'aozora2html'

class MultilineStyleTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_multiline_style_new
    tag = Multiline_style_tag.new(@parser,"style1")
    assert_equal Multiline_style_tag, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Multiline_style_tag.new(@parser,"s1")
    assert_equal "<div class=\"s1\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
