require "aozora2html/i18n"

# 例外class
class Aozora2Html
  class Error < StandardError

    def initialize(msg)
      @message = msg
      super
    end

    def message(line = 0)
      I18n.t(:error_stop, line, @message)
    end
  end
end

