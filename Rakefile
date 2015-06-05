require 'rubygems'
require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

task :default => [:test]

Rake::TestTask.new("test") do |t|
  t.libs   << "tests"
  t.test_files = Dir.glob("tests/**/test_*.rb")
  t.verbose = true
end
