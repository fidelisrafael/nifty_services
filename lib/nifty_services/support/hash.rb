unless Hash.method_defined?(:symbolize_keys)
  class Hash
    def symbolize_keys
      Hash[self.map {|k, v| [k.to_sym, v] }]
    end
  end
end
