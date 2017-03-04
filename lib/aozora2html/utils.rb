# encoding: utf-8
class Aozora2Html
  module Utils

    def create_font_size(times, daisho)
      size = ""
      case times
      when 1
        size = ""
      when 2
        size = "x-"
      else
        if times >= 3
          size = "xx-"
        else
          raise Aozora2Html::Error, I18n.t(:invalid_font_size)
        end
      end

      case daisho
      when :dai
        size << "large"
      when :sho
        size << "small"
      else
        raise Aozora2Html::Error, I18n.t(:invalid_font_size)
      end

      size
    end
    module_function :create_font_size

    def create_midashi_tag(size)
      if size.match(SIZE_SMALL)
        "h5"
      elsif size.match(SIZE_MIDDLE)
        "h4"
      elsif size.match(SIZE_LARGE)
        "h3"
      else
        raise Aozora2Html::Error.new(I18n.t(:undefined_header))
      end
    end
    module_function :create_midashi_tag

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

