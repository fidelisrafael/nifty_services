unless Hash.method_defined?(:symbolize_keys) && Hash.method_defined?(:slice)
  class Hash
    def symbolize_keys
      Hash[self.map {|k, v| [k.to_sym, v] }]
    end

    def slice(*keys)
      keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
      keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end
  end
end
