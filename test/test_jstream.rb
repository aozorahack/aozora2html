require 'test_helper'
require 'aozora2xhtml'
require 'stringio'

class JstreamTest < Test::Unit::TestCase
  def test_new_error
    strio = StringIO.new("aaa\nbbb\n")
    orig_stdout = $stdout
    out = StringIO.new
    $stdout = out
    assert_raises(SystemExit) do
      Jstream.new(strio)
    end
    $stdout = orig_stdout
    assert_equal "エラー(1行目):改行コードを、「CR+LF」にあらためてください. \r\n処理を停止します\n", out.string.encode("utf-8")
  end

  def test_read_char
    strio = StringIO.new("aあ５\r\n％\\b\r\n".encode("Shift_JIS"))
    stm = Jstream.new(strio)
    assert_equal "a", stm.read_char.encode("utf-8")
    assert_equal "あ", stm.read_char.encode("utf-8")
    assert_equal "５", stm.read_char.encode("utf-8")
    assert_equal "\r\n", stm.read_char.encode("utf-8")
    assert_equal "％", stm.read_char.encode("utf-8")
    assert_equal "\\", stm.read_char.encode("utf-8")
    assert_equal "b", stm.read_char.encode("utf-8")
    assert_equal "\r\n", stm.read_char.encode("utf-8")
    assert_equal :eof, stm.read_char
    assert_equal "\r\n", stm.read_char  # XXX ??
    assert_equal :eof, stm.read_char    # XXX ??
  end

  def test_peek_char
    strio = StringIO.new("aあ５\r\n％\\b\r\n".encode("Shift_JIS"))
    stm = Jstream.new(strio)
    assert_equal "a", stm.peek_char(0).encode("utf-8")
    assert_equal "あ", stm.peek_char(1).encode("utf-8")
    assert_equal "５", stm.peek_char(2).encode("utf-8")
    assert_equal "\r\n", stm.peek_char(3).encode("utf-8")
    assert_equal "\r\n", stm.peek_char(4).encode("utf-8") # XXX ??
    assert_equal "\r\n", stm.peek_char(5).encode("utf-8") # XXX ??
    assert_equal "\r\n", stm.peek_char(100).encode("utf-8") # XXX ??
    assert_equal "a", stm.read_char.encode("utf-8")

    assert_equal "あ", stm.peek_char(0).encode("utf-8")
    assert_equal "あ", stm.read_char.encode("utf-8")
    assert_equal "５", stm.read_char.encode("utf-8")
    assert_equal "\r\n", stm.read_char.encode("utf-8")

    assert_equal "％", stm.peek_char(0).encode("utf-8")
    assert_equal "\\", stm.peek_char(1).encode("utf-8")
    assert_equal "b", stm.peek_char(2).encode("utf-8")
    assert_equal "\r\n", stm.peek_char(3).encode("utf-8")
  end
end


