# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class MultilineMidashiTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
    stub(@parser).new_midashi_id{2}
  end

  def test_multiline_midashi_new
    tag = Multiline_midashi_tag.new(@parser,"小".encode("shift_jis"),:normal)
    assert_equal Multiline_midashi_tag, tag.class
    assert_equal true, tag.kind_of?(Block_tag)
    assert_equal true, tag.kind_of?(Multiline_tag)
  end

  def test_to_s
    tag = Multiline_midashi_tag.new(@parser,"小".encode("shift_jis"),:normal)
    assert_equal "<h5 class=\"ko-midashi\"><a class=\"midashi_anchor\" id=\"midashi2\">", tag.to_s
    assert_equal "</a></h5>", tag.close_tag
  end

  def test_to_s_chu
    tag = Multiline_midashi_tag.new(@parser,"中".encode("shift_jis"),:dogyo)
    assert_equal "<h4 class=\"dogyo-naka-midashi\"><a class=\"midashi_anchor\" id=\"midashi2\">", tag.to_s
    assert_equal "</a></h4>", tag.close_tag
  end

  def test_to_s_dai
    tag = Multiline_midashi_tag.new(@parser,"大".encode("shift_jis"),:mado)
    assert_equal "<h3 class=\"mado-o-midashi\"><a class=\"midashi_anchor\" id=\"midashi2\">", tag.to_s
    assert_equal "</a></h3>", tag.close_tag
  end

  def test_undeined_midashi
    begin
      Multiline_midashi_tag.new(@parser,"あ".encode("shift_jis"),:mado)
    rescue Aozora2Html::Error => e
      assert_equal e.message(123).encode("utf-8"), "エラー(123行目):未定義な見出しです. \r\n処理を停止します"
    end
  end

  def test_undeined_midashi2
    begin
      Multiline_midashi_tag.new(@parser,"大".encode("shift_jis"),:madoo)
    rescue Aozora2Html::Error => e
      assert_equal e.message(123).encode("utf-8"), "エラー(123行目):未定義な見出しです. \r\n処理を停止します"
    end
  end

  def teardown
  end
end
