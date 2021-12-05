# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class I18nTest < Test::Unit::TestCase
  def test_t
    assert_equal '警告(123行目):JIS外字「①」が使われています',
                 Aozora2Html::I18n.t(:warn_jis_gaiji,
                                     123,
                                     '①'.encode('cp932').force_encoding('shift_jis'))
                                  .force_encoding('cp932').encode('utf-8')
  end

  def test_ruby_puts_behavior
    $stdout = StringIO.new
    begin
      puts '①'.encode('cp932').force_encoding('shift_jis')
      assert_equal "①\n", $stdout.string.force_encoding('cp932').encode('utf-8')
    ensure
      $stdout = STDOUT
    end
  end
end
