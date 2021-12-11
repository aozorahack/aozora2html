# frozen_string_literal: true

require_relative 'i18n'

class Aozora2Html
  # 例外class
  class Error < StandardError
    def initialize(msg)
      super
      @message = msg
    end

    def message(line = 0)
      I18n.t(:error_stop, line, @message)
    end
  end
end
