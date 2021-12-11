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

    # 使うべきではない文字があるかチェックする
    #
    # 警告を出力するだけで結果には影響を与えない。警告する文字は以下:
    #
    # * 1バイト文字
    # * `＃`ではなく`♯`
    # * JIS(JIS X 0208)外字
    #
    # @return [void]
    #
    def illegal_char_check(char, line)
      return unless char.is_a?(String)

      code = char.unpack1('H*')
      if (code == '21') ||
         (code == '23') ||
         ((code >= 'a1') && (code <= 'a5')) ||
         ((code >= '28') && (code <= '29')) ||
         (code == '5b') ||
         (code == '5d') ||
         (code == '3d') ||
         (code == '3f') ||
         (code == '2b') ||
         ((code >= '7b') && (code <= '7d'))
        puts I18n.t(:warn_onebyte, line, char)
      end

      if code == '81f2'
        puts I18n.t(:warn_chuki, line, char)
      end

      if ((code >= '81ad') && (code <= '81b7')) ||
         ((code >= '81c0') && (code <= '81c7')) ||
         ((code >= '81cf') && (code <= '81d9')) ||
         ((code >= '81e9') && (code <= '81ef')) ||
         ((code >= '81f8') && (code <= '81fb')) ||
         ((code >= '8240') && (code <= '824e')) ||
         ((code >= '8259') && (code <= '825f')) ||
         ((code >= '827a') && (code <= '8280')) ||
         ((code >= '829b') && (code <= '829e')) ||
         ((code >= '82f2') && (code <= '82fc')) ||
         ((code >= '8397') && (code <= '839e')) ||
         ((code >= '83b7') && (code <= '83be')) ||
         ((code >= '83d7') && (code <= '83fc')) ||
         ((code >= '8461') && (code <= '846f')) ||
         ((code >= '8492') && (code <= '849e')) ||
         ((code >= '84bf') && (code <= '84fc')) ||
         ((code >= '8540') && (code <= '85fc')) ||
         ((code >= '8640') && (code <= '86fc')) ||
         ((code >= '8740') && (code <= '87fc')) ||
         ((code >= '8840') && (code <= '889e')) ||
         ((code >= '9873') && (code <= '989e')) ||
         ((code >= 'eaa5') && (code <= 'eafc')) ||
         ((code >= 'eb40') && (code <= 'ebfc')) ||
         ((code >= 'ec40') && (code <= 'ecfc')) ||
         ((code >= 'ed40') && (code <= 'edfc')) ||
         ((code >= 'ee40') && (code <= 'eefc')) ||
         ((code >= 'ef40') && (code <= 'effc'))
        puts I18n.t(:warn_jis_gaiji, line, char)
      end
    end
    module_function :illegal_char_check
  end
end
