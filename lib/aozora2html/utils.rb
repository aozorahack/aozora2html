# encoding: utf-8
class Aozora2Html
  module Utils
    def create_midashi_class(type, tag)
      case type
      when :normal
        case tag
        when "h5"
          "ko-midashi"
        when "h4"
          "naka-midashi"
        when "h3"
          "o-midashi"
        end
      when :dogyo
        case tag
        when "h5"
          "dogyo-ko-midashi"
        when "h4"
          "dogyo-naka-midashi"
        when "h3"
          "dogyo-o-midashi"
        end
      when :mado
        case tag
        when "h5"
          "mado-ko-midashi"
        when "h4"
          "mado-naka-midashi"
        when "h3"
          "mado-o-midashi"
        end
      else
        raise Aozora2Html::Error.new(I18n.t(:undefined_header))
      end
    end
    module_function :create_midashi_class
  end
end

