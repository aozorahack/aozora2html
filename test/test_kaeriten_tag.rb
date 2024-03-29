# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class KaeritenTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  def test_kaeriten_new
    tag = Aozora2Html::Tag::Kaeriten.new(@parser, 'aaa')
    assert_equal Aozora2Html::Tag::Kaeriten, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  using Aozora2Html::StringRefinements

  def test_to_s
    tag = Aozora2Html::Tag::Kaeriten.new(@parser, 'テスト'.to_sjis)
    assert_equal '<sub class="kaeriten">テスト</sub>', tag.to_s.to_utf8
  end

  def teardown
  end
end
