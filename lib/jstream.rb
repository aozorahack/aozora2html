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
class Jstream
  CR = "\r"
  LF = "\n"
  CRLF = CR + LF

  # 初期化と同時に、いったん最初の行をscanして、改行コードがCR+LFかどうか調べる。
  # CR+LFでない場合はエラーメッセージを出力してexitする(!)
  #
  # TODO: 将来的にはさすがにexitまではしないよう、仕様を変更する?
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
        exit(2)
      end
    ensure
      @file.rewind
    end
  end

  def inspect
    "#<jcode-stream input #{@file.inspect}>"
  end

  # 1文字読み込んで返す
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
      @current_char = char + char2
    elsif char.nil?
      @current_char = :eof
    else
      @current_char = char
    end

    @current_char
  end

  # pos個分の文字を先読みし、最後の文字を返す
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

        char += char2
      end
    ensure
      @file.seek(original_pos)
    end

    char
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
end
