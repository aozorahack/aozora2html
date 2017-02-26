require "aozora2html/tag"

class Aozora2Html
  class Tag
    class Accent < Aozora2Html::Tag
      alias_method :to_s_orig, :to_s

      def self.use_jisx0213=(val)
        @use_jisx0213 = val
      end

      def self.use_jisx0213
        @use_jisx0213
      end

      def jisx0213_to_unicode(code)
        Aozora2Html::JIS2UCS[code]
      end

      def to_s
        if Aozora2Html::Tag::Accent.use_jisx0213
          jisx0213_to_unicode(@code.sub(%r|.*/|,"").to_sym)
        else
          to_s_orig
        end
      end
    end
  end
end
