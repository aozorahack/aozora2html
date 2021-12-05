class Aozora2Html
  module Utils
    def create_font_size(times, daisho)
      size = ''
      case times
      when 1
        size = ''
      when 2
        size = 'x-'
      else
        raise Aozora2Html::Error, I18n.t(:invalid_font_size) unless times >= 3

        size = 'xx-'
      end

      case daisho
      when :dai
        size << 'large'
      when :sho
        size << 'small'
      else
        raise Aozora2Html::Error, I18n.t(:invalid_font_size)
      end

      size
    end
    module_function :create_font_size

    def create_midashi_tag(size)
      if size.match(SIZE_SMALL)
        'h5'
      elsif size.match(SIZE_MIDDLE)
        'h4'
      elsif size.match(SIZE_LARGE)
        'h3'
      else
        raise Aozora2Html::Error, I18n.t(:undefined_header)
      end
    end
    module_function :create_midashi_tag

    def create_midashi_class(type, tag)
      case type
      when :normal
        case tag
        when 'h5'
          'ko-midashi'
        when 'h4'
          'naka-midashi'
        when 'h3'
          'o-midashi'
        end
      when :dogyo
        case tag
        when 'h5'
          'dogyo-ko-midashi'
        when 'h4'
          'dogyo-naka-midashi'
        when 'h3'
          'dogyo-o-midashi'
        end
      when :mado
        case tag
        when 'h5'
          'mado-ko-midashi'
        when 'h4'
          'mado-naka-midashi'
        when 'h3'
          'mado-o-midashi'
        end
      else
        raise Aozora2Html::Error, I18n.t(:undefined_header)
      end
    end
    module_function :create_midashi_class

    def convert_japanese_number(command)
      tmp = command.tr('０-９'.encode('shift_jis'), '0-9')
      tmp.tr!('一二三四五六七八九〇'.encode('shift_jis'), '1234567890')
      tmp.gsub!(/(\d)#{"十".encode("shift_jis")}(\d)/) { "#{$1}#{$2}" }
      tmp.gsub!(/(\d)#{"十".encode("shift_jis")}/) { "#{$1}0" }
      tmp.gsub!(/#{"十".encode("shift_jis")}(\d)/) { "1#{$1}" }
      tmp.gsub!(/#{"十".encode("shift_jis")}/, '10')
      tmp
    end
    module_function :convert_japanese_number
  end
end
