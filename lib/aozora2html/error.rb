require "aozora2html/i18n"

# 例外class
class Aozora2Html
  class Error < StandardError

    def initialize(message)
      @message = message
    end

    def message(line)
      I18n.t(:error_stop, line, @message)
    end
  end
end

