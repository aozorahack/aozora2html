require 'test_helper'
require 'aozora2html'

class JizumeTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_jizume_new
    tag = Aozora2Html::Tag::Jizume.new(@parser,50)
    assert_equal Aozora2Html::Tag::Jizume, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Jizume.new(@parser,50)
    assert_equal "<div class=\"jizume_50\" style=\"width: 50em\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
