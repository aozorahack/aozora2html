# frozen_string_literal: true

require_relative 'aozora2html/error'
require_relative 'aozora2html/i18n'

##
# Stream class for reading a file.
#
# It's just a wrapper class of IO to read characters.
# when finished to read IO, return a symbol :eof.
# when found line terminator except CR+LF, exit.
#
# Internal processing is done in UTF-8.
# Input can be Shift_JIS or UTF-8; Shift_JIS is converted to UTF-8.
#
class Jstream
  CR = "\r"
  LF = "\n"
  CRLF = CR + LF

  # 初期化と同時に、いったん最初の行をscanして、改行コードがCR+LFかどうか調べる。
  # CR+LFでない場合はエラーメッセージを出力して、例外Aozora2Html::FatalErrorを上げる
  def initialize(file_io)
    @line = 0
    @current_char = nil
    @file = file_io

    begin
      tmp = @file.readline.chomp!("\r\n")
      raise Aozora2Html::Error, Aozora2Html::I18n.t(:use_crlf) unless tmp
    rescue Aozora2Html::Error => e
      puts e.message(1)
      if e.is_a?(Aozora2Html::Error)
        raise Aozora2Html::FatalError
      end
    ensure
      @file.rewind
    end
  end

  def inspect
    "#<jcode-stream input #{@file.inspect}>"
  end

  # 1文字読み込んで返す (UTF-8に変換して返す)
  #
  # 行末の場合は(1文字ではなく)CR+LFを返す
  # EOFまで到達すると :eof というシンボルを返す
  #
  # TODO: EOFの場合はnilを返すように変更する?
  def read_char
    char = @file.getc

    if char == CR
      char2 = @file.getc
      if char2 != LF
        raise Aozora2Html::Error, Aozora2Html::I18n.t(:use_crlf)
      end

      @line += 1
      @current_char = CRLF
    elsif char.nil?
      @current_char = :eof
    else
      @current_char = to_utf8(char)
    end

    @current_char
  end

  # pos個分の文字を先読みし、最後の文字を返す (UTF-8に変換して返す)
  #
  # ファイルディスクリプタは移動しない（実行前の位置まで戻す）
  # 行末の場合は(1文字ではなく)CR+LFを返す
  # 行末の先に進んだ場合の挙動は未定義になる
  def peek_char(pos)
    original_pos = @file.pos
    char = nil

    begin
      pos.times { read_char }

      char = @file.getc
      if char == CR
        char2 = @file.getc
        if char2 != LF
          raise Aozora2Html::Error, Aozora2Html::I18n.t(:use_crlf)
        end

        char = CRLF
      elsif char
        char = to_utf8(char)
      end
    ensure
      @file.seek(original_pos)
    end

    char
  end

  # 指定された終端文字(1文字のStringかCRLF)まで読み込む
  #
  #  @param [String] endchar 終端文字
  def read_to(endchar)
    buf = +''
    loop do
      char = read_char
      break if char == endchar

      if char.is_a?(Symbol)
        print endchar
      end
      buf.concat(char)
    end
    buf
  end

  # 1行読み込み
  #
  # @return [String] 読み込んだ文字列を返す
  #
  def read_line
    read_to("\r\n")
  end

  def close
    @file.close
  end

  # 現在の行数を返す
  #
  # 何も読み込む前は0、読み込み始めの最初の文字から\r\nまでが1、その次の文字から次の\r\nは2、……といった値になる
  def line
    if @file.pos == 0
      0
    elsif @current_char == CRLF
      @line
    else
      @line + 1
    end
  end

  private

  # Shift_JIS文字をUTF-8に変換する
  def to_utf8(char)
    return char if char.nil? || char.encoding == Encoding::UTF_8

    char.encode(Encoding::UTF_8)
  end
end
