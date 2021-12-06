# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 外字注記用
    class EmbedGaiji < Aozora2Html::Tag::Gaiji
      attr_accessor :unicode

      @use_jisx0213 = nil
      @use_unicode = nil

      class << self
        attr_writer :use_jisx0213
      end

      class << self
        attr_reader :use_jisx0213
      end

      class << self
        attr_writer :use_unicode
      end

      class << self
        attr_reader :use_unicode
      end

      def initialize(parser, folder, code, name, unicode_num = nil, gaiji_dir:)
        @folder = folder
        @code = code
        @name = name
        @unicode = unicode_num
        @gaiji_dir = gaiji_dir
        super
      end

      def jisx0213_to_unicode(code)
        Aozora2Html::JIS2UCS[code]
      end

      def to_s
        if Aozora2Html::Tag::EmbedGaiji.use_jisx0213 && @code
          jisx0213_to_unicode(@code.to_sym)
        elsif Aozora2Html::Tag::EmbedGaiji.use_unicode && @unicode
          "&#x#{@unicode};"
        else
          "<img src=\"#{@gaiji_dir}#{@folder}/#{@code}.png\" alt=\"" + GAIJI_MARK + "(#{@name})\" class=\"gaiji\" />"
        end
      end
    end
  end
end
