require 'test_helper'
require 'aozora2html'

class MultilineCaptionTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_multiline_caption_new
    tag = Aozora2Html::Tag::MultilineCaption.new(@parser0)
    assert_equal Aozora2Html::Tag::MultilineCaption, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::MultilineCaption.new(@parser)
    assert_equal "<div class=\"caption\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
