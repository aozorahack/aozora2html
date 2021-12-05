# frozen_string_literal: true

require 'test_helper'
require 'aozora2html'

class HeaderTest < Test::Unit::TestCase
  def setup
    @header = Aozora2Html::Header.new
  end

  def test_header_to_html
    @header.push('武装せる市街'.encode('shift_jis'))
    @header.push('黒島伝治'.encode('shift_jis'))
    actual = @header.to_html.encode('utf-8')
    expected =
      "<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>\r\n" +
      "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"\r\n" +
      "    \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\r\n" +
      "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" >\r\n" +
      "<head>\r\n" +
      "\t<meta http-equiv=\"Content-Type\" content=\"text/html;charset=Shift_JIS\" />\r\n" +
      "\t<meta http-equiv=\"content-style-type\" content=\"text/css\" />\r\n" +
      "\t<link rel=\"stylesheet\" type=\"text/css\" href=\"../../aozora.css\" />\r\n" +
      "\t<title>黒島伝治 武装せる市街</title>\r\n" +
      "\t<script type=\"text/javascript\" src=\"../../jquery-1.4.2.min.js\"></script>\r\n" +
      "  <link rel=\"Schema.DC\" href=\"http://purl.org/dc/elements/1.1/\" />\r\n" +
      "\t<meta name=\"DC.Title\" content=\"武装せる市街\" />\r\n" +
      "\t<meta name=\"DC.Creator\" content=\"黒島伝治\" />\r\n" +
      "\t<meta name=\"DC.Publisher\" content=\"青空文庫\" />\r\n" +
      "</head>\r\n" +
      "<body>\r\n" +
      "<div class=\"metadata\">\r\n" +
      "<h1 class=\"title\">武装せる市街</h1>\r\n" +
      "<h2 class=\"author\">黒島伝治</h2>\r\n" +
      "<br />\r\n" +
      "<br />\r\n" +
      "</div>\r\n" +
      '<div id="contents" style="display:none"></div><div class="main_text">'
    assert_equal(expected, actual)
  end

  def test_build_title
    @header.push('武装せる市街'.encode('shift_jis'))
    @header.push('黒島伝治'.encode('shift_jis'))
    header_info = @header.build_header_info()
    actual = @header.build_title(header_info).encode('utf-8')
    expected = '<title>黒島伝治 武装せる市街</title>'
    assert_equal(expected, actual)
  end

  def test_build_title2
    @header.push('スリーピー・ホローの伝説'.encode('shift_jis'))
    @header.push('故ディードリッヒ・ニッカボッカーの遺稿より'.encode('shift_jis'))
    @header.push('ワシントン・アーヴィング　Washington Irving'.encode('shift_jis'))
    @header.push('吉田甲子太郎訳'.encode('shift_jis'))
    header_info = @header.build_header_info()
    actual = @header.build_title(header_info).encode('utf-8')
    expected = '<title>ワシントン・アーヴィング　Washington Irving 吉田甲子太郎訳 スリーピー・ホローの伝説 故ディードリッヒ・ニッカボッカーの遺稿より</title>'
    assert_equal(expected, actual)
  end
end
