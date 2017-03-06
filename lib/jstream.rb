require "aozora2html/error"
require "aozora2html/i18n"

##
# Stream class for reading a file.
#
# It's just a wrapper class of IO to read characters.
# when finished to read IO, return a symbol :eof.
# when found line terminator except CR+LF, exit.
#
class Jstream

  attr_accessor :line

  def initialize(file_io)
    @line = 0
    @entry = false
    @file = file_io
    begin
      store_to_buffer
    rescue Aozora2Html::Error => e
      puts e.message(1)
      if e.is_a?(Aozora2Html::Error)
        exit(2)
      end
    end
  end

  def inspect
    "#<jcode-stream input " + @file.inspect + ">"
  end

  def read_char
    found = @buffer.shift
    if @entry
      @line += 1
      @entry = false
    end
    if found
      return found
    end

    begin
      store_to_buffer
    rescue EOFError
      @buffer = [:eof]
    end
    "\r\n"
  end

  def peek_char(pos)
    @buffer[pos] || "\r\n"
  end

  def close
    @file.close
  end

  private
  def store_to_buffer
    if tmp = @file.readline.chomp!("\r\n")
      @buffer = tmp.each_char.to_a
    else
      raise Aozora2Html::Error, Aozora2Html::I18n.t(:use_crlf)
    end
    @entry = true
  end
end
