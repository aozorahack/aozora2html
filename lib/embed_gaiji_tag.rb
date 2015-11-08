class Embed_Gaiji_tag
  alias_method :to_s_orig, :to_s
  attr_accessor :unicode

  def self.use_jisx0213=(val)
    @use_jisx0213 = val
  end

  def self.use_jisx0213
    @use_jisx0213
  end

  def self.use_unicode=(val)
    @use_unicode = val
  end

  def self.use_unicode
    @use_unicode
  end

  def jisx0213_to_unicode(code)
    Aozora2Html::JIS2UCS[code]
  end

  def to_s
    if Embed_Gaiji_tag.use_jisx0213 && @code
      jisx0213_to_unicode(@code.to_sym)
    elsif Embed_Gaiji_tag.use_unicode && @unicode
      '&#x'+@unicode+';'
    else
      to_s_orig
    end
  end
end
