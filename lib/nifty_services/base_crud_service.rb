module NiftyServices
  class BaseCrudService < BaseService

    attr_reader :record

    class << self
      def record_type(record_type, options = {})
        define_method :record_type do
          record_type
        end

        record_alias = options.delete(:alias_name) || record_type.to_s.underscore

        alias_method record_alias.to_sym, :record
      end
    end

    def initialize(record, options = {})
      @record = record

      super(options)
    end

    def changed_attributes
      []
    end

    def changed?
      changed_attributes.any?
    end

    def record_type
      not_implemented_exception(__method__)
    end

    def record_attributes_hash
      not_implemented_exception(__method__)
    end

    def record_attributes_whitelist
      not_implemented_exception(__method__)
    end

    def record_allowed_attributes
      filter_hash(record_attributes_hash, record_attributes_whitelist)
    end

    alias :record_safe_attributes :record_allowed_attributes

    private
    def record_error_key
      record_type.to_s.pluralize.underscore
    end

    def valid_record?
      valid_object?(@record, record_type)
    end
  end
end
