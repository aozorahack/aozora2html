class Aozora2Html
  class StyleStack
    def initialize
      @stack = []
    end

    def push(elem)
      @stack.push(elem)
    end

    def empty?
      @stack.empty?
    end

    def pop
      @stack.pop
    end

    def last
      @stack.last
    end

    def last_command
      @stack.last[0]
    end
  end
end
