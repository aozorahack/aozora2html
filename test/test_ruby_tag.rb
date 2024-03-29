# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class RubyTagTest < Test::Unit::TestCase
  def setup
    @parser = Object.new
    stub(@parser).block_allowed_context? { true }
  end

  using Aozora2Html::StringRefinements

  def test_ruby_new
    tag = Aozora2Html::Tag::Ruby.new(@parser, 'aaa'.to_sjis, 'bb')
    assert_equal Aozora2Html::Tag::Ruby, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::Ruby.new(@parser, 'テスト'.to_sjis, 'てすと'.to_sjis)
    assert_equal '<ruby><rb>テスト</rb><rp>（</rp><rt>てすと</rt><rp>）</rp></ruby>', tag.to_s.to_utf8
  end

  def teardown
  end
end
