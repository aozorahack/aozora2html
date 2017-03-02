class Aozora2Html
  class RubyBuffer

    attr_accessor :protected
    attr_accessor :char_type

    def initialize(item=nil)
      clear(item)
    end

    def clear(item=nil)
      if item
        @ruby_buf = [item]
      else
        @ruby_buf = [""]
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
    def dump(buffer)
      if @protected
        @ruby_buf.unshift("｜")
        @protected = nil
      end
      top = @ruby_buf[0]
      if top.is_a?(String) and buffer.last.is_a?(String)
        buffer.last.concat(top)
        buffer.concat(@ruby_buf[1,@ruby_buf.length])
      else
        buffer.concat(@ruby_buf)
      end
      clear
      buffer
    end

  end
end

