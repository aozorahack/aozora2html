# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib/")
require 'test/unit'
require 'test/unit/rr'
require 'tmpdir'
require 'stringio'
# require 'test/unit/notify'
