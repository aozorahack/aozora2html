# frozen_string_literal: true

class Aozora2Html
  class Tag
    # インラインタグ用class
    #
    # 全ての青空記法はHTML elementに変換される
    # したがって、block/inlineの区別がある
    # 全ての末端青空classはどちらかのclassのサブクラスになる必要がある
    class Inline
      def initialize(*_args)
        true
      end
    end
  end
end
