# encoding: utf-8
require 'test_helper'
require 'aozora2html'

class EditorNoteTagTest < Test::Unit::TestCase
  def setup
  end

  def test_editor_note_new
    tag = Aozora2Html::Tag::EditorNote.new(nil,"注記のテスト".encode("shift_jis"))
    assert_equal Aozora2Html::Tag::EditorNote, tag.class
    assert_equal true, tag.kind_of?(Aozora2Html::Tag::Inline)
  end

  def test_to_s
    tag = Aozora2Html::Tag::EditorNote.new(nil,"注記のテスト".encode("shift_jis"))
    assert_equal "<span class=\"notes\">［＃注記のテスト］</span>", tag.to_s.encode("utf-8")
  end

  def teardown
  end
end
