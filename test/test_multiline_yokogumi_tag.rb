# frozen_string_literal: true

require_relative 'test_helper'
require 'aozora2html'

class MultilineYokogumiTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  def test_multiline_yokogumi_new
    tag = Aozora2Html::Tag::MultilineYokogumi.new(@parser)
    assert_equal Aozora2Html::Tag::MultilineYokogumi, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Block)
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::MultilineYokogumi.new(@parser)
    assert_equal '<div class="yokogumi">', tag.to_s
    assert_equal '</div>', tag.close_tag
  end

  def teardown
  end
end
