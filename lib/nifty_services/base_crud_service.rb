module NiftyServices
  module Concerns
  end

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

      def include_concern(namespace, concern_type)
        _module = "#{services_concern_namespace}::#{namespace.to_s.camelize}::#{concern_type.to_s.camelize}"

        self.include(_module.constantize)
      end

      def services_concern_namespace
        NiftyServices.config.service_concerns_namespace
      end

      alias_method :concern, :include_concern
    end

    def initialize(record, user, options = {})
      @record = record
      @user = user

      super(options)
    end

    def execute
      not_implemented_exception(__method__)
    end

    def record_type
      not_implemented_exception(__method__)
    end

    def record_params
      not_implemented_exception(__method__)
    end

    def record_params_whitelist
      not_implemented_exception(__method__)
    end

    def record_allowed_params
      filter_hash(record_params, record_params_whitelist)
    end

    alias :record_whitelisted_params :record_allowed_params
    alias :record_safe_params :record_allowed_params

    private
    def array_values_from_hash(options, key, root = nil)
      options = options.symbolize_keys

      if root.present?
        options = (options[root.to_sym] || {}).symbolize_keys
      end

      return [] unless options.key?(key.to_sym)

      values = options[key.to_sym]

      return values if values.is_a?(Array)

      array_values_from_string(values)
    end

    alias :array_values_from_params :array_values_from_hash

    def array_values_from_string(string)
      string.to_s.split(/\,/).map(&:squish)
    end

    def record_params
      not_implemented_exception(__method__)
    end

    def record_error_key
      record_type.to_s.pluralize.underscore
    end

    def valid_record?
      valid_object?(@record, record_type)
    end
  end
end
