# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class Aozora2HtmlBinTest < Test::Unit::TestCase
  def setup
    @input = './sample/chukiichiran_kinyurei.txt'
  end

  def test_exec_aozora2html
    Dir.mktmpdir do |dir|
      output = File.join(dir, 'out.html')
      cmd = "bundle exec aozora2html #{@input} #{output}"
      system(cmd)
      input_content = File.read('./sample/chukiichiran_kinyurei.html')
      output_content = File.read(output)
      assert_equal input_content, output_content
    end
  end

  def test_exec_aozora2html_jisx0213
    Dir.mktmpdir do |dir|
      output = File.join(dir, 'out.html')
      cmd = "bundle exec aozora2html --use-jisx0213 #{@input} #{output}"
      system(cmd)
      input_content = File.read('./sample/chukiichiran_kinyurei_jisx0213.html')
      output_content = File.read(output)
      assert_equal input_content, output_content
    end
  end

  def test_exec_aozora2html_unicode
    Dir.mktmpdir do |dir|
      output = File.join(dir, 'out.html')
      cmd = "bundle exec aozora2html --use-unicode #{@input} #{output}"
      system(cmd)
      input_content = File.read('./sample/chukiichiran_kinyurei_unicode.html')
      output_content = File.read(output)
      assert_equal input_content, output_content
    end
  end
end
