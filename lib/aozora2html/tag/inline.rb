# frozen_string_literal: true

class Aozora2Html
  class Tag
    # インライン記法用
    #
    # 全ての青空記法はHTML elementに変換される
    # したがって、block/inlineの区別がある
    # 全ての末端青空classはどちらかのmoduleをincludeする必要がある
    module Inline
      def initialize(*_args)
        true
      end
    end
  end
end
