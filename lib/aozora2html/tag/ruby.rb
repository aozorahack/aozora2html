# frozen_string_literal: true

# complex ruby markup
# if css3 is major supported, please fix ruby position with property "ruby-position"
# see also: http://www.w3.org/TR/2001/WD-css3-ruby-20010216/
class Aozora2Html
  class Tag
    # ルビ用
    #
    # 現状、under_rubyは無視しているのに注意
    class Ruby < Aozora2Html::Tag::ReferenceMentioned
      attr_accessor :ruby, :under_ruby
      attr_reader :target

      def initialize(parser, string, ruby, under_ruby = '')
        @target = string
        @ruby = ruby
        @under_ruby = under_ruby
        super
      end

      def to_s
        "<ruby><rb>#{@target}</rb><rp>#{PAREN_BEGIN_MARK}</rp><rt>#{@ruby}</rt><rp>#{PAREN_END_MARK}</rp></ruby>"
      end

      # rubyタグの再割り当て
      def self.rearrange_ruby(parser, targets, upper_ruby, under_ruby)
        unless include_ruby?(targets)
          return Aozora2Html::Tag::Ruby.new(parser, targets, upper_ruby, under_ruby)
        end

        new_targets = []
        new_upper = if upper_ruby == ''
                      []
                    else
                      upper_ruby
                    end
        new_under = if under_ruby == ''
                      []
                    else
                      under_ruby
                    end
        if (new_upper.length >= 1) && (new_under.length >= 1)
          raise Aozora2Html::Error, I18n.t(:dont_allow_triple_ruby)
        end

        targets.each do |x|
          case x
          when Aozora2Html::Tag::Ruby
            raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby) if x.target.is_a?(Array)

            if x.ruby == ''
              raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby) unless new_under.is_a?(Array)

              new_under.push(x.under_ruby)
            else
              raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby) unless new_upper.is_a?(Array)

              new_upper.push(x.ruby)
            end
            new_targets.push(x.target)
          when Aozora2Html::Tag::ReferenceMentioned
            if x.target.is_a?(Array)
              # recursive
              ruby2 = rearrange_ruby(parser, x.target, '', '')
              target2, upper_ruby2, under_ruby2 = ruby2.target, ruby2.ruby, ruby2.under_ruby
              # rotation!!
              target2.each do |y|
                tmp = x.dup
                tmp.target = y
                new_targets.push(tmp)
              end
              if new_under.is_a?(Array)
                new_under.concat(under_ruby2)
              elsif under_ruby2.to_s.length > 0
                raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
              end
              if new_upper.is_a?(Array)
                new_upper.concat(upper_ruby2)
              elsif upper_ruby2.to_s.length > 0
                raise Aozora2Html::Error, I18n.t(:dont_use_double_ruby)
              end
            else
              new_targets.push(x)
              if new_under.is_a?(Array)
                new_under.push('')
              end
              if new_upper.is_a?(Array)
                new_upper.push('')
              end
            end
          else
            new_targets.push(x)
            if new_under.is_a?(Array)
              new_under.push('')
            end
            if new_upper.is_a?(Array)
              new_upper.push('')
            end
          end
        end

        Aozora2Html::Tag::Ruby.new(parser, new_targets, new_upper, new_under)
      end

      # arrayがルビを含んでいればそのインデックスを返す
      #
      # @return [Integer, nil]
      #
      def self.include_ruby?(array)
        array.index do |elt|
          case elt
          when Aozora2Html::Tag::Ruby
            true
          when Aozora2Html::Tag::ReferenceMentioned
            if elt.target.is_a?(Array)
              include_ruby?(elt.target)
            else
              elt.target.is_a?(Aozora2Html::Tag::Ruby)
            end
          end
        end
      end

      # ----------------------------------------------------
      #
      # def gen_rt(string)
      #   if string == ''
      #     '<rt class="dummy_ruby"></rt>'
      #   else
      #     "<rt class=\"real_ruby\">#{string}</rt>"
      #   end
      # end
      #
      #
      # complex ruby is waiting for IE support and CSS3 candidate
      #   def to_s
      #     ans = "<ruby class=\"complex_ruby\"><rbc>" # indicator of new version of aozora ruby
      #     if @ruby.is_a?(Array) and @ruby.length > 0
      #       # cell is used
      #       @rbspan = @ruby.length
      #     end
      #     if @under_ruby.is_a?(Array) and @under_ruby.length > 0
      #       # cell is used, but two way cell is not supported
      #       if @rbspan
      #         raise Aozora2Html::Error, I18n.t(:unsupported_ruby)
      #       else
      #         @rbspan = @under_ruby.length
      #       end
      #     end
      #
      #     # target
      #     if @rbspan
      #       @target.each{|x|
      #         ans.concat("<rb>#{x.to_s}</rb>")
      #       }
      #     else
      #       ans.concat("<rb>#{@target.to_s}</rb>")
      #     end
      #
      #     ans.concat("</rbc><rtc>")
      #
      #     # upper ruby
      #     if @ruby.is_a?(Array)
      #       @ruby.each{|x|
      #         ans.concat(gen_rt(x))
      #       }
      #     elsif @rbspan
      #       if @ruby != ""
      #         ans.concat("<rt class=\"real_ruby\" rbspan=\"#{@rbspan}\">#{@ruby}</rt>")
      #       else
      #         ans.concat("<rt class=\"dummy_ruby\" rbspan=\"#{@rbspan}\"></rt>")
      #       end
      #     else
      #       ans.concat(gen_rt(@ruby))
      #     end
      #
      #     ans.concat("</rtc>")
      #
      #     # under_ruby (if exists)
      #     if @under_ruby.length > 0
      #       ans.concat("<rtc>")
      #       if @under_ruby.is_a?(Array)
      #         @under_ruby.each{|x|
      #           ans.concat(gen_rt(x))
      #         }
      #       elsif @rbspan
      #         ans.concat("<rt class=\"real_ruby\" rbspan=\"#{@rbspan}\">#{@under_ruby}</rt>")
      #       else
      #         ans.concat(gen_rt(@under_ruby))
      #       end
      #       ans.concat("</rtc>")
      #     end
      #
      #     # finalize
      #     ans.concat("</ruby>")
      #
      #     ans
      #   end
    end
  end
end
