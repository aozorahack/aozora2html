require 'test_helper'
require 'aozora2html'

class MultilineYokogumiTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_multiline_yokogumi_new
    tag = Multiline_yokogumi_tag.new(@parser0)
    assert_equal Multiline_yokogumi_tag, tag.class
    assert_equal true, tag.kind_of?(Block_tag)
    assert_equal true, tag.kind_of?(Multiline_tag)
  end

  def test_to_s
    tag = Multiline_yokogumi_tag.new(@parser)
    assert_equal "<div class=\"yokogumi\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
