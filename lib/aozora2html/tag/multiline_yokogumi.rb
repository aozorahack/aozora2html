class Aozora2Html
  class Tag
    class MultilineYokogumi < Aozora2Html::Tag
      include Aozora2Html::Tag::Multiline
      include Aozora2Html::Tag::Block

      def to_s
        '<div class="yokogumi">'
      end
    end
  end
end
