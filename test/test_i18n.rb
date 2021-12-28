# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class I18nTest < Test::Unit::TestCase
  using Aozora2Html::StringRefinements

  def test_t
    assert_equal '警告(123行目):JIS外字「①」が使われています',
                 Aozora2Html::I18n.t(:warn_jis_gaiji,
                                     123,
                                     '①'.encode('cp932').force_encoding('shift_jis'))
                                  .force_encoding('cp932').to_utf8
  end

  def test_error_utf8
    orig_value = Aozora2Html::I18n.use_utf8
    Aozora2Html::I18n.use_utf8 = true
    begin
      assert_equal '警告(123行目):JIS外字「①」が使われています',
                   Aozora2Html::I18n.t(:warn_jis_gaiji,
                                       123,
                                       '①'.encode('cp932').force_encoding('shift_jis'))
    ensure
      Aozora2Html::I18n.use_utf8 = orig_value
    end
  end

  def test_ruby_puts_behavior
    $stdout = StringIO.new
    begin
      puts '①'.encode('cp932').force_encoding('shift_jis')
      assert_equal "①\n", $stdout.string.force_encoding('cp932').to_utf8
    ensure
      $stdout = STDOUT
    end
  end
end
