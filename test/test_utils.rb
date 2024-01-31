# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class UtilsTest < Test::Unit::TestCase
  using Aozora2Html::StringRefinements

  def setup
  end

  def test_create_font_size()
    assert_equal('small', Aozora2Html::Utils.create_font_size(1, :sho))
    assert_equal('large', Aozora2Html::Utils.create_font_size(1, :dai))
    assert_equal('x-small', Aozora2Html::Utils.create_font_size(2, :sho))
    assert_equal('x-large', Aozora2Html::Utils.create_font_size(2, :dai))
    assert_equal('xx-small', Aozora2Html::Utils.create_font_size(3, :sho))
    assert_equal('xx-small', Aozora2Html::Utils.create_font_size(4, :sho))
    assert_raise(Aozora2Html::Error) { Aozora2Html::Utils.create_font_size(0, :sho) }
  end

  def test_create_midashi_tag()
    assert_equal('h5', Aozora2Html::Utils.create_midashi_tag('小'.to_sjis))
    assert_equal('h4', Aozora2Html::Utils.create_midashi_tag('中'.to_sjis))
    assert_equal('h3', Aozora2Html::Utils.create_midashi_tag('大'.to_sjis))
    assert_raise(Aozora2Html::Error) { Aozora2Html::Utils.create_midashi_tag('標準'.to_sjis) }
  end

  def test_convert_japanese_number()
    assert_equal('1', Aozora2Html::Utils.convert_japanese_number('１'.to_sjis))
    assert_equal('2', Aozora2Html::Utils.convert_japanese_number('２'.to_sjis))
    assert_equal('8', Aozora2Html::Utils.convert_japanese_number('８'.to_sjis))
    assert_equal('9', Aozora2Html::Utils.convert_japanese_number('９'.to_sjis))
    assert_equal('10', Aozora2Html::Utils.convert_japanese_number('１０'.to_sjis))
    assert_equal('11', Aozora2Html::Utils.convert_japanese_number('１１'.to_sjis))
    assert_equal('1', Aozora2Html::Utils.convert_japanese_number('一'.to_sjis))
    assert_equal('2', Aozora2Html::Utils.convert_japanese_number('二'.to_sjis))
    assert_equal('8', Aozora2Html::Utils.convert_japanese_number('八'.to_sjis))
    assert_equal('9', Aozora2Html::Utils.convert_japanese_number('九'.to_sjis))
    assert_equal('10', Aozora2Html::Utils.convert_japanese_number('十'.to_sjis))
    assert_equal('10', Aozora2Html::Utils.convert_japanese_number('一〇'.to_sjis))
    assert_equal('11', Aozora2Html::Utils.convert_japanese_number('十一'.to_sjis))
    assert_equal('11', Aozora2Html::Utils.convert_japanese_number('一一'.to_sjis))
    assert_equal('13', Aozora2Html::Utils.convert_japanese_number('十三'.to_sjis))
    assert_equal('19', Aozora2Html::Utils.convert_japanese_number('十九'.to_sjis))
    assert_equal('20', Aozora2Html::Utils.convert_japanese_number('二十'.to_sjis))
    assert_equal('24', Aozora2Html::Utils.convert_japanese_number('二十四'.to_sjis))
    assert_equal('24', Aozora2Html::Utils.convert_japanese_number('二四'.to_sjis))
  end
end
