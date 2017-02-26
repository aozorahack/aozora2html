# 変換される青空記法class
class Aozora2Html
  class Tag
    # debug用
    def inspect
      to_s
    end

    def syntax_error
      raise Aozora2Html::Error.new(I18n.t(:tag_syntax_error))
    end
  end
end
