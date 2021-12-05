class Aozora2Html
  class RubyBuffer
    # `｜`が来た時に真にする。ルビの親文字のガード用。
    attr_accessor :protected

    # @ruby_buf内の文字のchar_type
    attr_accessor :char_type

    def initialize(item = nil)
      clear(item)
    end

    # バッファの初期化。引数itemがあるときはその1要素のバッファに、
    # 引数がなければ`""`の1要素のバッファにする。
    def clear(item = nil)
      @ruby_buf = if item
                    [item]
                  else
                    ['']
                  end
      @protected = nil
      @char_type = nil
    end

    def empty?
      @ruby_buf.empty?
    end

    def present?
      !empty?
    end

    def to_a
      @ruby_buf
    end

    def each(&block)
      @ruby_buf.each(&block)
    end

    def last
      @ruby_buf.last
    end

    def push(item)
      @ruby_buf.push(item)
    end

    def length
      @ruby_buf.length
    end

    def last_concat(item)
      @ruby_buf.last.concat(item)
    end

    def last_is_string?
      @ruby_buf.last.is_a?(String)
    end

    # buffer management
    def dump_into(buffer)
      if @protected
        @ruby_buf.unshift(RUBY_PREFIX)
        @protected = nil
      end
      top = @ruby_buf[0]
      if top.is_a?(String) && buffer.last.is_a?(String)
        buffer.last.concat(top)
        buffer.concat(@ruby_buf[1, @ruby_buf.length])
      else
        buffer.concat(@ruby_buf)
      end
      clear
      buffer
    end
  end
end
