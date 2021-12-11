# frozen_string_literal: true

class Aozora2Html
  class Tag
    # 参照先用
    #
    # 前方参照でこいつだけは中身をチェックする
    # 子要素を持つAozora2Html::Tag::Inlineは全てこいつのサブクラス
    class ReferenceMentioned < Aozora2Html::Tag
      include Aozora2Html::Tag::Inline
      attr_accessor :target

      def initialize(*_args) # rubocop:disable Lint/MissingSuper
        return unless defined?(@target) && block_element?(@target)

        syntax_error
      end

      def block_element?(elt)
        case elt
        when Array
          elt.each do |x|
            if block_element?(x)
              return true
            end
          end
          nil
        when String
          elt.include?('<div')
        else
          elt.is_a?(Aozora2Html::Tag::Block)
        end
      end

      def target_string
        case @target
        when Aozora2Html::Tag::ReferenceMentioned
          @target.target_string
        when Array
          @target.collect do |x|
            if x.is_a?(Aozora2Html::Tag::ReferenceMentioned)
              x.target_string
            else
              x
            end
          end.to_s
        else
          @target
        end
      end
    end
  end
end
