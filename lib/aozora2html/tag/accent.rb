# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 欧文アクセント文字用
    class Accent < Aozora2Html::Tag::Inline
      @use_jisx0213 = nil

      class << self
        attr_accessor :use_jisx0213
      end

      def initialize(parser, code, name, gaiji_dir:, use_jisx0213: nil)
        @code = code
        @name = name
        @gaiji_dir = gaiji_dir
        @use_jisx0213 = use_jisx0213
        super
      end

      def jisx0213_to_unicode(code)
        Aozora2Html::JIS2UCS[code]
      end

      def char_type
        :hankaku
      end

      def to_s
        if Aozora2Html::Tag::Accent.use_jisx0213 || @use_jisx0213
          jisx0213_to_unicode(@code.sub(%r{.*/}, '').to_sym)
        else
          "<img src=\"#{@gaiji_dir}#{@code}.png\" alt=\"" + GAIJI_MARK + "(#{@name})\" class=\"gaiji\" />"
        end
      end
    end
  end
end
