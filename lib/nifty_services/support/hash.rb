unless Hash.method_defined?(:symbolize_keys)
  class Hash
   def symbolize_keys
      self.keys.each do |key|
        self[key.to_sym] = self.delete(key)
      end
      self
    end
  end
end