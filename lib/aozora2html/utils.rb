# frozen_string_literal: true

class Aozora2Html
  # ユーティリティ関数モジュール
  module Utils
    def create_font_size(times, daisho)
      size = case times
             when 1
               +''
             when 2
               +'x-'
             else
               raise Aozora2Html::Error, I18n.t(:invalid_font_size) unless times >= 3

               +'xx-'
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
      normal_midashi_tag = {
        'h5' => 'ko-midashi',
        'h4' => 'naka-midashi',
        'h3' => 'o-midashi'
      }

      dogyo_midashi_tag = {
        'h5' => 'dogyo-ko-midashi',
        'h4' => 'dogyo-naka-midashi',
        'h3' => 'dogyo-o-midashi'
      }

      mado_midashi_tag = {
        'h5' => 'mado-ko-midashi',
        'h4' => 'mado-naka-midashi',
        'h3' => 'mado-o-midashi'
      }

      case type
      when :normal
        normal_midashi_tag[tag]
      when :dogyo
        dogyo_midashi_tag[tag]
      when :mado
        mado_midashi_tag[tag]
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
