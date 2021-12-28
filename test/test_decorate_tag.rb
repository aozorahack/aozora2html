# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class DecorateTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  def test_decorate_new
    tag = Aozora2Html::Tag::Decorate.new(@parser, 'aa', 1, :dai)
    assert_equal Aozora2Html::Tag::Decorate, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  using Aozora2Html::StringRefinements

  def test_to_s
    tag = Aozora2Html::Tag::Decorate.new(@parser, 'テスト'.to_sjis, 'foo', 'span')
    assert_equal '<span class="foo">テスト</span>', tag.to_s.to_utf8
  end

  def teardown
  end
end
