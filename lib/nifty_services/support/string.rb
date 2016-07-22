unless String.method_defined?(:underscore)
  class String
   def underscore
      return self unless self =~ /[A-Z-]|::/
      word = self.to_s.gsub('::'.freeze, '/'.freeze)
      word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)((?=a)b)(?=\b|[^a-z])/) { "#{$1 && '_'.freeze }#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
      word.tr!("-".freeze, "_".freeze)
      word.downcase!
      word
    end
  end
end