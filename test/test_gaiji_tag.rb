# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class EmbedGaijiTagTest < Test::Unit::TestCase
  def setup
    @orig_gaiji_dir = $gaiji_dir
    $gaiji_dir = "g_dir/"
  end

  def test_gaiji_new
    egt = Aozora2Html::Tag::EmbedGaiji.new(nil,"foo","1-2-3","name")
    assert_equal "<img src=\"g_dir/foo/1-2-3.png\" alt=\"※(name)\" class=\"gaiji\" />", egt.to_s.encode("utf-8")
  end

  def test_unembed_gaiji_new
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil,"テストtest".encode("Shift_JIS"))
    assert_equal "<span class=\"notes\">［テストtest］</span>", egt.to_s.encode("utf-8")
  end

  def test_espcaed?
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil,"テストtest".encode("Shift_JIS"))
    assert_equal false, egt.escaped?
  end

  def test_espcae!
    egt = Aozora2Html::Tag::UnEmbedGaiji.new(nil,"テストtest".encode("Shift_JIS"))
    egt.escape!
    assert_equal true, egt.escaped?
  end

  def test_jisx0213
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = true
    egt = Aozora2Html::Tag::EmbedGaiji.new(nil,"foo","1-06-75","snowman")
    assert_equal "&#x2603;", egt.to_s.encode("utf-8")
  end

  def teardown
    Aozora2Html::Tag::EmbedGaiji.use_jisx0213 = false
    $gaiji_dir = @orig_gaiji_dir
  end
end
