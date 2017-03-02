# 前方参照でこいつだけは中身をチェックする
# 子要素を持つAozora2Html::Tag::Inlineは全てこいつのサブクラス
class Aozora2Html
  class Tag
    class ReferenceMentioned < Aozora2Html::Tag
      include Aozora2Html::Tag::Inline
      attr_accessor :target

      def initialize(*args)
        if defined?(@target) && block_element?(@target)
          syntax_error
        end
      end

      def block_element?(elt)
        if elt.is_a?(Array)
          elt.each{|x|
            if block_element?(x)
              return true
            end
          }
          nil
        elsif elt.is_a?(String)
          elt.match(/<div/)
        else
          elt.is_a?(Aozora2Html::Tag::Block)
        end
      end

      def target_string
        if @target.is_a?(Aozora2Html::Tag::ReferenceMentioned)
          @target.target_string
        elsif @target.is_a?(Array)
          @target.collect{|x|
            if x.is_a?(Aozora2Html::Tag::ReferenceMentioned)
              x.target_string
            else
              x
            end}.to_s
        else
          @target
        end
      end
    end
  end
end
