# frozen_string_literal: true

require_relative 'test_helper'
require 'aozora2html'

class CompatTest < Test::Unit::TestCase
  def test_array_to_s
    assert_equal 'abc', ['a', 'b', 'c'].join
  end
end
