# frozen_string_literal: true

class Aozora2Html
  # 見出しIDカウンター
  #
  # 主にmidashi_idを管理する
  class MidashiCounter
    def initialize(current_id)
      @midashi_id = current_id
    end

    def generate_id(size)
      if size.is_a?(Integer)
        @midashi_id += size
        return @midashi_id
      end

      case size
      when /#{Aozora2Html::SIZE_SMALL}/o
        inc = 1
      when /#{Aozora2Html::SIZE_MIDDLE}/o
        inc = 10
      when /#{Aozora2Html::SIZE_LARGE}/o
        inc = 100
      else
        raise Aozora2Html::Error, I18n.t(:undefined_header)
      end

      @midashi_id += inc
    end
  end
end
