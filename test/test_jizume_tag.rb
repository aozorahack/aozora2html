require 'test_helper'
require 'aozora2html'

class JizumeTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_jizume_new
    tag = Jizume_tag.new(@parser,50)
    assert_equal Jizume_tag, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Multiline_tag)
  end

  def test_to_s
    tag = Jizume_tag.new(@parser,50)
    assert_equal "<div class=\"jizume_50\" style=\"width: 50em\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
