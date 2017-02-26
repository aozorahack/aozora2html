require 'test_helper'
require 'aozora2html'

class KeigakomiTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_keigakomi_new
    tag = Keigakomi_tag.new(@parser,2)
    assert_equal Keigakomi_tag, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Multiline_tag)
  end

  def test_to_s
    tag = Keigakomi_tag.new(@parser)
    assert_equal "<div class=\"keigakomi\" style=\"border: solid 1px\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def test_to_s2
    tag = Keigakomi_tag.new(@parser,2)
    assert_equal "<div class=\"keigakomi\" style=\"border: solid 2px\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
