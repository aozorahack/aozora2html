# frozen_string_literal: true

require 'rubygems'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/clean'

task default: [:test]

Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.test_files = Dir.glob('test/**/test_*.rb')
  t.verbose = true
end

desc 'convert sample/chukiichiran_kinyurei.txt'
task :chuuki do
  sh 'bundle exec aozora2html --error-utf8 sample/chukiichiran_kinyurei.txt sample/chukiichiran_kinyurei.html'
end
