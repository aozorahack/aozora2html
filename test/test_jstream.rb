# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'
require 'stringio'

class JstreamTest < Test::Unit::TestCase
  using Aozora2Html::StringRefinements

  def test_new_error
    strio = StringIO.new("aaa\nbbb\n")
    orig_stdout = $stdout
    out = StringIO.new
    $stdout = out
    assert_raises(Aozora2Html::FatalError) do
      Jstream.new(strio)
    end
    $stdout = orig_stdout
    assert_equal "エラー(1行目):改行コードを、「CR+LF」にあらためてください. \r\n処理を停止します\n", out.string.to_utf8
  end

  def test_read_char
    strio = StringIO.new("aあ５\r\n％\\b\r\n".to_sjis)
    stm = Jstream.new(strio)
    assert_equal 'a', stm.read_char.to_utf8
    assert_equal 'あ', stm.read_char.to_utf8
    assert_equal '５', stm.read_char.to_utf8
    assert_equal "\r\n", stm.read_char.to_utf8
    assert_equal '％', stm.read_char.to_utf8
    assert_equal '\\', stm.read_char.to_utf8
    assert_equal 'b', stm.read_char.to_utf8
    assert_equal "\r\n", stm.read_char.to_utf8
    assert_equal :eof, stm.read_char
    # assert_equal "\r\n", stm.read_char  # :eof以降は正しい値を保証しない
    assert_equal :eof, stm.read_char # 何度もread_charすると:eofが複数回出る
  end

  def test_peek_char
    strio = StringIO.new("aあ５\r\n％\\b\r\n".to_sjis)
    stm = Jstream.new(strio)
    assert_equal 'a', stm.peek_char(0).to_utf8
    assert_equal 'あ', stm.peek_char(1).to_utf8
    assert_equal '５', stm.peek_char(2).to_utf8
    assert_equal "\r\n", stm.peek_char(3).to_utf8
    # assert_equal "\r\n", stm.peek_char(4).to_utf8 # 改行文字以降は正しい値を保証しない
    # assert_equal "\r\n", stm.peek_char(5).to_utf8 # 同上
    # assert_equal "\r\n", stm.peek_char(100).to_utf8 # 同上
    assert_equal 'a', stm.read_char.to_utf8

    assert_equal 'あ', stm.peek_char(0).to_utf8
    assert_equal 'あ', stm.read_char.to_utf8
    assert_equal '５', stm.read_char.to_utf8
    assert_equal "\r\n", stm.read_char.to_utf8

    assert_equal '％', stm.peek_char(0).to_utf8
    assert_equal '\\', stm.peek_char(1).to_utf8
    assert_equal 'b', stm.peek_char(2).to_utf8
    assert_equal "\r\n", stm.peek_char(3).to_utf8
  end
end
