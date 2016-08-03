class Object
  unless method_defined?(:try!)
    # File activesupport/lib/active_support/core_ext/object/try.rb, line 69
    def try!(*a, &b)
      if a.empty? && block_given?
        if b.arity == 0
          instance_eval(&b)
        else
          yield self
        end
      else
        public_send(*a, &b)
      end
    end
  end

  unless method_defined?(:try)
    # File activesupport/lib/active_support/core_ext/object/try.rb, line 62
    def try(*a, &b)
      try!(*a, &b) if a.empty? || respond_to?(a.first)
    end
  end
end
