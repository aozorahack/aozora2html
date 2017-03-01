# encoding: utf-8
# complex ruby markup
# if css3 is major supported, please fix ruby position with property "ruby-position"
# see also: http://www.w3.org/TR/2001/WD-css3-ruby-20010216/
class Aozora2Html
  class Tag
    class Ruby < Aozora2Html::Tag::ReferenceMentioned
      attr_accessor :ruby, :under_ruby

      def initialize(parser, string, ruby, under_ruby = "")
        @target = string
        @ruby = ruby
        @under_ruby = under_ruby
        super
      end

      def gen_rt(string)
        if string != ""
          "<rt class=\"real_ruby\">#{string}</rt>"
        else
          "<rt class=\"dummy_ruby\"></rt>"
        end
      end

      def to_s
        "<ruby><rb>#{@target.to_s}</rb><rp>" + "（".encode("shift_jis") + "</rp><rt>#{@ruby.to_s}</rt><rp>" + "）".encode("shift_jis") + "</rp></ruby>"
      end

# complex ruby is waiting for IE support and CSS3 candidate
=begin
  def to_s
    ans = "<ruby class=\"complex_ruby\"><rbc>" # indicator of new version of aozora ruby
    if @ruby.is_a?(Array) and @ruby.length > 0
      # cell is used
      @rbspan = @ruby.length
    end
    if @under_ruby.is_a?(Array) and @under_ruby.length > 0
      # cell is used, but two way cell is not supported
      if @rbspan
        raise Aozora2Html::Error.new("サポートされていない複雑なルビ付けです")
      else
        @rbspan = @under_ruby.length
      end
    end

    # target
    if @rbspan
      @target.each{|x|
        ans.concat("<rb>#{x.to_s}</rb>")
      }
    else
      ans.concat("<rb>#{@target.to_s}</rb>")
    end

    ans.concat("</rbc><rtc>")

    # upper ruby
    if @ruby.is_a?(Array)
      @ruby.each{|x|
        ans.concat(gen_rt(x))
      }
    elsif @rbspan
      if @ruby != ""
        ans.concat("<rt class=\"real_ruby\" rbspan=\"#{@rbspan}\">#{@ruby}</rt>")
      else
        ans.concat("<rt class=\"dummy_ruby\" rbspan=\"#{@rbspan}\"></rt>")
      end
    else
      ans.concat(gen_rt(@ruby))
    end

    ans.concat("</rtc>")

    # under_ruby (if exists)
    if @under_ruby.length > 0
      ans.concat("<rtc>")
      if @under_ruby.is_a?(Array)
        @under_ruby.each{|x|
          ans.concat(gen_rt(x))
        }
      elsif @rbspan
        ans.concat("<rt class=\"real_ruby\" rbspan=\"#{@rbspan}\">#{@under_ruby}</rt>")
      else
        ans.concat(gen_rt(@under_ruby))
      end
      ans.concat("</rtc>")
    end

    # finalize
    ans.concat("</ruby>")

    ans
  end
=end

    end
  end
end
