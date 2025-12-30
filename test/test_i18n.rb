# frozen_string_literal: true

require_relative 'test_helper'
require 'aozora2html'

class I18nTest < Test::Unit::TestCase
  def test_t
    assert_equal '警告(123行目):JIS外字「①」が使われています',
                 Aozora2Html::I18n.t(:warn_jis_gaiji, 123, '①')
  end
end
