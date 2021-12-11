# frozen_string_literal: true

class Aozora2Html
  # スタイルの状態管理用スタック
  #
  # スタイルの入れ子を扱えるようにスタック構造になっている。
  # 各要素は`[コマンド文字列, 閉じる際に使うHTML文字列]`という2要素の配列になっている。
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
