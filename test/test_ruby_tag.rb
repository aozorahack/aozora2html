# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class RubyTagTest < Test::Unit::TestCase
  def setup
    stub(@parser).block_allowed_context?{true}
  end

  def test_ruby_new
    tag = Aozora2Html::Tag::Ruby.new(@parser,"aaa".encode("shift_jis"),"bb")
    assert_equal Aozora2Html::Tag::Ruby, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Ruby.new(@parser,"テスト".encode("shift_jis"),"てすと".encode("shift_jis"))
    assert_equal "<ruby><rb>テスト</rb><rp>（</rp><rt>てすと</rt><rp>）</rp></ruby>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
