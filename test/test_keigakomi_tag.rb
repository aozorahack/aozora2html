# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class KeigakomiTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  def test_keigakomi_new
    tag = Aozora2Html::Tag::Keigakomi.new(@parser, 2)
    assert_equal Aozora2Html::Tag::Keigakomi, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Block)
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Keigakomi.new(@parser)
    assert_equal '<div class="keigakomi" style="border: solid 1px">', tag.to_s
    assert_equal '</div>', tag.close_tag
  end

  def test_to_s2
    tag = Aozora2Html::Tag::Keigakomi.new(@parser, 2)
    assert_equal '<div class="keigakomi" style="border: solid 2px">', tag.to_s
    assert_equal '</div>', tag.close_tag
  end

  def teardown
  end
end
