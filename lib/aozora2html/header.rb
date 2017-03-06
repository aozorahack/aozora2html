# encoding: utf-8
class Aozora2Html
  class Header
    def initialize()
      @header = []
    end

    def push(line)
      @header.push(line)
    end

    def out_header_info(hash, attr, true_name = nil)
      found = hash[attr]
      if found
        "<h2 class=\"#{true_name or attr}\">#{found}</h2>\r\n"
      else
        ""
      end
    end

    def header_element_type(string)
      original = true
      string.each_char do |x|
        code = x.unpack("H*")[0]
        if ("00" <= code and code <= "7f") or # 1byte
          ("8140" <= code and code <= "8258") or # 1-1, 3-25
          ("839f" <= code and code <= "8491") # 6-1, 7-81
        # continue
        else
          original = false
          break
        end
      end
      if original
        :original
      elsif string.match(PAT_EDITOR)
        :editor
      elsif string.match(PAT_HENYAKU)
        :henyaku
      elsif string.match(PAT_TRANSLATOR)
        :translator
      end
    end

    def process_person(string, header_info)
      type = header_element_type(string)
      case type
      when :editor
        header_info[:editor] = string
      when :translator
        header_info[:translator] = string
      when :henyaku
        header_info[:henyaku] = string
      else
        type = :author
        header_info[:author] = string
      end
      type
    end

    def build_title(header_info)
      buf = [:author, :translator, :editor, :henyaku,
             :title, :original_title,
             :subtitle, :original_subtitle].map{|item| header_info[item]}.compact
      buf_str = buf.join(" ")
      "<title>#{buf_str}</title>"
    end

    def build_header_info
      header_info = {:title => @header[0]}
      case @header.length
      when 2
        process_person(@header[1], header_info)
      when 3
        if header_element_type(@header[1]) == :original
          header_info[:original_title] = @header[1]
          process_person(@header[2], header_info)
        elsif process_person(@header[2], header_info) == :author
          header_info[:subtitle] = @header[1]
        else
          header_info[:author] = @header[1]
        end
      when 4
        if header_element_type(@header[1]) == :original
          header_info[:original_title] = @header[1]
        else
          header_info[:subtitle] = @header[1]
        end
        if process_person(@header[3], header_info) == :author
          header_info[:subtitle] = @header[2]
        else
          header_info[:author] = @header[2]
        end
      when 5
        header_info[:original_title] = @header[1]
        header_info[:subtitle] = @header[2]
        header_info[:author] = @header[3]
        if process_person(@header[4], header_info) == :author
          raise Aozora2Html::Error.new("parser encounted author twice")
        end
      when 6
        header_info[:original_title] = @header[1]
        header_info[:subtitle] = @header[2]
        header_info[:original_subtitle] = @header[3]
        header_info[:author] = @header[4]
        if process_person(@header[5], header_info) == :author
          raise Aozora2Html::Error.new("parser encounted author twice")
        end
      end
      header_info
    end

    def to_html
      header_info = build_header_info()

      # <title> 行を構築
      html_title = build_title(header_info)

      # 出力
      out_buf = []
      out_buf.push("<?xml version=\"1.0\" encoding=\"Shift_JIS\"?>\r\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"\r\n    \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">\r\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" >\r\n<head>\r\n	<meta http-equiv=\"Content-Type\" content=\"text/html;charset=Shift_JIS\" />\r\n	<meta http-equiv=\"content-style-type\" content=\"text/css\" />\r\n")
      $css_files.each do |css|
        out_buf.push("\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + css + "\" />\r\n")
      end
      out_buf.push("\t#{html_title}\r\n	<script type=\"text/javascript\" src=\"../../jquery-1.4.2.min.js\"></script>\r\n  <link rel=\"Schema.DC\" href=\"http://purl.org/dc/elements/1.1/\" />\r\n	<meta name=\"DC.Title\" content=\"#{header_info[:title]}\" />\r\n	<meta name=\"DC.Creator\" content=\"#{header_info[:author]}\" />\r\n	<meta name=\"DC.Publisher\" content=\"#{AOZORABUNKO}\" />\r\n</head>\r\n<body>\r\n<div class=\"metadata\">\r\n")
      out_buf.push("<h1 class=\"title\">#{header_info[:title]}</h1>\r\n" +
                   out_header_info(header_info, :original_title) +
                   out_header_info(header_info, :subtitle) +
                   out_header_info(header_info, :original_subtitle) +
                   out_header_info(header_info, :author) +
                   out_header_info(header_info, :editor) +
                   out_header_info(header_info, :translator) +
                   out_header_info(header_info, :henyaku, "editor-translator"))
      out_buf.push("<br />\r\n<br />\r\n</div>\r\n<div id=\"contents\" style=\"display:none\"></div><div class=\"main_text\">")
      out_buf.join("")
    end

  end
end
