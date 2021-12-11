# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 書字方向（LTR）の指定用
    class Dir < Aozora2Html::Tag::ReferenceMentioned
      def initialize(parser, target)
        @target = target
        super
      end

      def to_s
        "<span dir=\"ltr\">#{@target}</span>"
      end
    end
  end
end
