require 'test_helper'
require 'aozora2html'

class ImgTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true} 
  end

  def test_img_new
    tag = Img_tag.new(@parser,"foo.png","img1","alt img1",40,50)
    assert_equal Img_tag, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Img_tag.new(@parser,"foo.png","img1","alt img1",40,50)
    assert_equal "<img class=\"img1\" width=\"40\" height=\"50\" src=\"foo.png\" alt=\"alt img1\" />", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
