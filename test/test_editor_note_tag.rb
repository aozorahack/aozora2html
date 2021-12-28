# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class EditorNoteTagTest < Test::Unit::TestCase
  def setup
  end

  using Aozora2Html::StringRefinements

  def test_editor_note_new
    tag = Aozora2Html::Tag::EditorNote.new(nil, '注記のテスト'.to_sjis)
    assert_equal Aozora2Html::Tag::EditorNote, tag.class
    assert_equal true, tag.is_a?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::EditorNote.new(nil, '注記のテスト'.to_sjis)
    assert_equal '<span class="notes">［＃注記のテスト］</span>', tag.to_s.to_utf8
  end

  def teardown
  end
end
