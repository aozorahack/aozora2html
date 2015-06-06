require 'test_helper'
require 'aozora2html'

class DirTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_dir_new
    tag = Dir_tag.new(@parser,"テスト".encode("shift_jis"))
    assert_equal Dir_tag, tag.class
    assert_equal true, tag.kind_of?(Inline_tag)
  end

  def test_to_s
    tag = Dir_tag.new(@parser,"テスト".encode("shift_jis"))
    assert_equal "<span dir=\"ltr\">テスト</span>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
