# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class MultilineMidashiTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
    stub(@parser).new_midashi_id { 2 }
  end

  using Aozora2Html::StringRefinements

  def test_multiline_midashi_new
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser, '小'.to_sjis, :normal)
    assert_equal Aozora2Html::Tag::MultilineMidashi, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Block)
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Multiline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser, '小'.to_sjis, :normal)
    assert_equal '<h5 class="ko-midashi"><a class="midashi_anchor" id="midashi2">', tag.to_s
    assert_equal '</a></h5>', tag.close_tag
  end

  def test_to_s_chu
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser, '中'.to_sjis, :dogyo)
    assert_equal '<h4 class="dogyo-naka-midashi"><a class="midashi_anchor" id="midashi2">', tag.to_s
    assert_equal '</a></h4>', tag.close_tag
  end

  def test_to_s_dai
    tag = Aozora2Html::Tag::MultilineMidashi.new(@parser, '大'.to_sjis, :mado)
    assert_equal '<h3 class="mado-o-midashi"><a class="midashi_anchor" id="midashi2">', tag.to_s
    assert_equal '</a></h3>', tag.close_tag
  end

  def test_undeined_midashi
    Aozora2Html::Tag::MultilineMidashi.new(@parser, 'あ'.to_sjis, :mado)
  rescue Aozora2Html::Error => e
    assert_equal e.message(123).to_utf8, "エラー(123行目):未定義な見出しです. \r\n処理を停止します"
  end

  def test_undeined_midashi2
    Aozora2Html::Tag::MultilineMidashi.new(@parser, '大'.to_sjis, :madoo)
  rescue Aozora2Html::Error => e
    assert_equal e.message(123).to_utf8, "エラー(123行目):未定義な見出しです. \r\n処理を停止します"
  end

  def teardown
  end
end
