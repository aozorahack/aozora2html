# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class InlineYokogumiTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  def test_yokogumi_new
    tag = Aozora2Html::Tag::InlineYokogumi.new(@parser, 'aaa')
    assert_equal Aozora2Html::Tag::InlineYokogumi, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  using Aozora2Html::StringRefinements

  def test_to_s
    tag = Aozora2Html::Tag::InlineYokogumi.new(@parser, 'テスト'.to_sjis)
    assert_equal '<span class="yokogumi">テスト</span>', tag.to_s.to_utf8
  end

  def teardown
  end
end
