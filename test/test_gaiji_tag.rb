# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class EmbedGaijiTagTest < Test::Unit::TestCase
  def setup
    @gaiji_dir = 'g_dir/'
  end

  using Aozora2Html::StringRefinements

  def test_gaiji_new
    egt = Aozora2Html::Tag::EmbedGaiji.new(nil, 'foo', '1-2-3', 'name', gaiji_dir: @gaiji_dir)
    assert_equal '<img src="g_dir/foo/1-2-3.png" alt="※(name)" class="gaiji" />', egt.to_s.to_utf8
  end

  def test_unembed_gaiji_new
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil, 'テストtest'.to_sjis)
    assert_equal '<span class="notes">［テストtest］</span>', egt.to_s.to_utf8
  end

  def test_espcaed?
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil, 'テストtest'.to_sjis)
    assert_equal false, egt.escaped?
  end

  def test_espcae!
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil, 'テストtest'.to_sjis)
    egt.escape!
    assert_equal true, egt.escaped?
  end

  def test_jisx0213
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = true
    egt = Aozora2Html::Tag::EmbedGaiji.new(nil, 'foo', '1-06-75', 'snowman', gaiji_dir: @gaiji_dir)
    assert_equal '&#x2603;', egt.to_s.to_utf8
  end

  def test_use_unicode
    Aozora2Html::Tag::EmbedGaiji.use_unicode = true
    egt = Aozora2Html::Tag::EmbedGaiji.new(nil, 'foo', '1-06-75', 'snowman', '2603', gaiji_dir: @gaiji_dir)
    assert_equal '&#x2603;', egt.to_s.to_utf8
  end

  def teardown
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = false
    Aozora2Html::Tag::EmbedGaiji.use_unicode = false
  end
end
