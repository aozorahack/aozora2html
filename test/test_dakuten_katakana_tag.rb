# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class DakutenKatakanaTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    @gaiji_dir = 'g_dir'
    stub(@parser).block_allowed_context? { true }
  end

  using Aozora2Html::StringRefinements

  def test_dakuten_katakana_new
    tag = Aozora2Html::Tag::DakutenKatakana.new(@parser, 1, 'ア'.to_sjis, gaiji_dir: @gaiji_dir)
    assert_equal Aozora2Html::Tag::DakutenKatakana, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::DakutenKatakana.new(@parser, 1, 'ア'.to_sjis, gaiji_dir: @gaiji_dir)
    assert_equal '<img src="g_dir/1-07/1-07-81.png" alt="※(濁点付き片仮名「ア」、1-07-81)" class="gaiji" />', tag.to_s.to_utf8
  end
end
