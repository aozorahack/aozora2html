require 'test_helper'
require 'aozora2xhtml'

class CompatTest < Test::Unit::TestCase
  def test_array_to_s
    assert_equal "abc", ["a", "b", "c"].join
  end
end



