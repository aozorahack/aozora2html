# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class ExceptionTest < Test::Unit::TestCase
  def test_raise_aozora_exception
    assert_raises(Aozora2Html::Error) do
      raise Aozora2Html::Error, 'error!'
    end
  end

  using Aozora2Html::StringRefinements

  def test_raise_aozora_error
    error_msg = ''
    begin
      raise Aozora2Html::Error, 'sample error'
    rescue Aozora2Html::Error => e
      error_msg = e.message(123)
    end
    assert_equal "エラー(123行目):sample error. \r\n処理を停止します",
                 error_msg.to_utf8
  end
end
