require "aozora2html/error"
require "aozora2html/i18n"

class Jstream

  attr_accessor :line

  def store_to_buffer
    if tmp = @file.readline.chomp!("\r\n")
      @buffer = tmp.each_char.to_a
    else
      raise Aozora2Html::Error.new(Aozora2Html::I18n.t(:use_crlf))
    end
    @entry = true
  end

  def initialize (file_io)
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
      @line = @line + 1
      @entry = false
    end
    if found
      found
    else
      begin
        store_to_buffer
        "\r\n"
      rescue EOFError
        @buffer = [:eof]
        "\r\n"
      end
    end
  end

  def peek_char (pos)
    found = @buffer[pos]
    if found
      found
    else
      "\r\n"
    end
  end

  def close
    @file.close
  end
end
