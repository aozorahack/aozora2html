class Embed_Gaiji_tag
  alias_method :to_s_orig, :to_s

  def self.use_jisx0213=(val)
    @use_jisx0213 = val
  end

  def self.use_jisx0213
    @use_jisx0213
  end

  def jisx0213_to_unicode(code)
    Aozora2Html::JIS2UCS[code]
  end

  def to_s
    if Embed_Gaiji_tag.use_jisx0213
      jisx0213_to_unicode(@code.to_sym)
    else
      to_s_orig
    end
  end
end
