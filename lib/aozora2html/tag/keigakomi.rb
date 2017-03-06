class Aozora2Html::Tag::Keigakomi < Aozora2Html::Tag
  include Aozora2Html::Tag::Block, Aozora2Html::Tag::Multiline

  def initialize(parser, size = 1)
    @size = size
    super
  end

  def to_s
    "<div class=\"keigakomi\" style=\"border: solid #{@size}px\">"
  end
end

