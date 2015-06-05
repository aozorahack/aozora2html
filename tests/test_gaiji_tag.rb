require 'test_helper'
require 'aozora2xhtml'

class EmbedGaijiTagTest < Test::Unit::TestCase
  def setup
    @orig_gaiji_dir = $gaiji_dir
    $gaiji_dir = "g_dir/"
  end

  def test_gaiji_new
    egt = Embed_Gaiji_tag.new(nil,"foo","1-2-3","name")
    assert_equal "<img src=\"g_dir/foo/1-2-3.png\" alt=\"※(name)\" class=\"gaiji\" />", egt.to_s.encode("utf-8")
  end

  def test_unembed_gaiji_new
    egt = UnEmbed_Gaiji_tag.new(nil,"テストtest".encode("Shift_JIS"))
    assert_equal "<span class=\"notes\">［テストtest］</span>", egt.to_s.encode("utf-8")
  end

  def teardown
    $gaiji_dir = @orig_gaiji_dir
  end
end
