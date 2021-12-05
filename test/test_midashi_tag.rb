# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class MidashiTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
    stub(@parser).new_midashi_id { 2 }
  end

  def test_midashi_new
    tag = Aozora2Html::Tag::Midashi.new(@parser, 'テスト見出し'.encode('shift_jis'), '小'.encode('shift_jis'), :normal)
    assert_equal Aozora2Html::Tag::Midashi, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Midashi.new(@parser, 'テスト見出し'.encode('shift_jis'), '小'.encode('shift_jis'), :normal)
    assert_equal '<h5 class="ko-midashi"><a class="midashi_anchor" id="midashi2">' + 'テスト見出し'.encode('shift_jis') + '</a></h5>', tag.to_s
  end

  def test_to_s_mado
    tag = Aozora2Html::Tag::Midashi.new(@parser, 'テスト見出し'.encode('shift_jis'), '小'.encode('shift_jis'), :mado)
    assert_equal '<h5 class="mado-ko-midashi"><a class="midashi_anchor" id="midashi2">' + 'テスト見出し'.encode('shift_jis') + '</a></h5>', tag.to_s
  end

  def test_undeined_midashi
    begin
      Aozora2Html::Tag::Midashi.new(@parser, 'テスト見出し'.encode('shift_jis'), 'あ'.encode('shift_jis'), :normal)
    rescue Aozora2Html::Error => e
      assert_equal e.message(123).encode('utf-8'), "エラー(123行目):未定義な見出しです. \r\n処理を停止します"
    end
  end

  def teardown
  end
end
