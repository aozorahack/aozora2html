require 'test_helper'
require 'aozora2html'

class MultilineYokogumiTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_multiline_yokogumi_new
    tag = Aozora2Html::Tag::MultilineYokogumi.new(@parser0)
    assert_equal Aozora2Html::Tag::MultilineYokogumi, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::MultilineYokogumi.new(@parser)
    assert_equal "<div class=\"yokogumi\">", tag.to_s
    assert_equal "</div>", tag.close_tag
  end

  def teardown
  end
end
