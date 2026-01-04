# frozen_string_literal: true

##
# Output stream wrapper that converts UTF-8 to Shift_JIS on write.
#
# This class wraps an IO object and converts all UTF-8 strings
# to Shift_JIS before writing to the underlying stream.
#
class OutputStream
  def initialize(io)
    @io = io
  end

  def print(*args)
    args.each do |arg|
      @io.print(to_sjis(arg))
    end
  end

  def printf(format, *args)
    converted_args = args.map { |arg| arg.is_a?(String) ? to_sjis(arg) : arg }
    @io.printf(to_sjis(format), *converted_args)
  end

  def puts(*args)
    args.each do |arg|
      @io.puts(to_sjis(arg))
    end
  end

  def write(str)
    @io.write(to_sjis(str))
  end

  def close
    @io.close
  end

  private

  def to_sjis(obj)
    return obj unless obj.is_a?(String)
    return obj if obj.encoding == Encoding::Shift_JIS

    obj.encode(Encoding::Shift_JIS)
  end
end
