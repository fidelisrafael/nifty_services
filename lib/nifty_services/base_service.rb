require File.expand_path('extensions/callbacks', File.dirname(__FILE__))
require 'i18n'

module NiftyServices
  class BaseService

    attr_reader :response_status, :response_status_code
    attr_reader :options, :errors, :logger

    class << self
      def register_error_response_method(reason_string, status_code)
        NiftyServices::Configuration.add_response_error_method(reason_string, status_code)
        define_error_response_method(reason_string, status_code)
      end

      def define_error_response_method(reason_string, status_code)
        method_name = Util.normalized_callback_name(reason_string, '_error')

        define_method method_name do |message_key, options = {}|
          error(status_code, message_key, options)
        end

        define_method "#{method_name}!" do |message_key, options = {}|
          error!(status_code, message_key, options)
        end
      end
    end

    def initialize(options = {}, initial_response_status = 400)
      @options = with_default_options(options)
      @errors = []
      @logger = @options[:logger] || default_logger

      @executed = false

      with_before_and_after_callbacks(:initialize) do
        set_response_status(initial_response_status)
      end
    end

    def execute
      not_implemented_exception(__method__)
    end

    def valid?
      return @errors.empty?
    end

    def success?
      @success == true && valid?
    end

    def fail?
      !success?
    end

    def response_status
      @response_status ||= :bad_request
    end

    def valid_user?
      user_class = NiftyServices.config.user_class

      raise 'Invalid User class. Use NitfyService.config.user_class = ClassName' if user_class.nil?

      valid_object?(@user, user_class)
    end

    def option_exists?(key)
      @options && @options.key?(key.to_sym)
    end

    def option_enabled?(key)
      option_exists?(key) && @options[key.to_sym] == true
    end

    def option_disabled?(key)
      !option_enabled?(key)
    end

    def add_error(error)
      add_method = error.is_a?(Array) ? :concat : :push
      @errors.send(add_method, error)
    end

    def default_logger
      NiftyServices.config.logger
    end

    alias :log :logger

    def executed?
      @executed == true
    end

    alias :runned? :executed?

    private
    def with_default_options(options)
      default_options.merge(options).symbolize_keys
    end

    def default_options
      {}
    end

    def can_execute?
      not_implemented_exception(__method__)
    end

    def execute_action(&block)
      begin
        return nil if executed?

        with_before_and_after_callbacks(:execute) do
          if can_execute?
            yield(block) if block_given?
          end
        end

        @executed = true
      rescue Exception => e
        add_error(e)
      end

      self # allow chaining
    end

    def success_response(status = :ok)
      unless Configuration::SUCCESS_RESPONSE_STATUS.key?(status.to_sym)
        raise "#{status} is not a valid success response status"
      end

      with_before_and_after_callbacks(:success) do
        @success = true
        set_response_status(status)
      end
    end

    def success_created_response
      success_response(:created)
    end

    def set_response_status(status)
      @response_status = response_status_reason_for(status)
      @response_status_code = response_status_code_for(status)
    end

    def response_status_for(status)
      error_list = Configuration::ERROR_RESPONSE_STATUS
      success_list = Configuration::SUCCESS_RESPONSE_STATUS

      select_method = [Symbol, String].member?(status.class) ? :key : :value

      response_list = error_list.merge(success_list)

      response_list.select do |status_key, status_code|
        status == (select_method == :key ? status_key : status_code)
      end
    end

    def response_status_code_for(status)
      response_status_for(status).values.first
    end

    def response_status_reason_for(status)
      response_status_for(status).keys.first
    end

    def error(status, message_key, options = {})
      @success = false

      with_before_and_after_callbacks(:error) do
        set_response_status(status)

        error_message = process_error_message_for_key(message_key, options)
        add_error(error_message)

        error_message
      end
    end

    def error!(status, message_key, options = {})
      error(status, message_key, options)

      # TODO:
      # maybe throw a Exception making bang(!) semantic
      # raise "NiftyServices::V1::Exceptions::#{status.titleize}".constantize
      return false
    end

    def valid_object?(record, expected_class)
      record.is_a?(expected_class)
    end

    def filter_hash(hash = {}, whitelist_keys = [])
      hash.symbolize_keys.slice(*whitelist_keys.map(&:to_sym))
    end

    def changes(old, current, attributes = {})
      changes = []

      return changes if old.nil? || current.nil?

      old_attributes = old.attributes.slice(*attributes.map(&:to_s))
      new_attributes = current.attributes.slice(*attributes.map(&:to_s))

      new_attributes.each do |attribute, value|
        changes << attribute if (old_attributes[attribute] != value)
      end

      changes.map(&:to_sym)
    end

    def i18n_namespace
      NiftyServices.configuration.i18n_namespace
    end

    def i18n_errors_namespace
      "#{i18n_namespace}.errors"
    end

    def process_error_message_for_key(message_key, options)
      if message_key.class.to_s == 'ActiveModel::Errors'
        message = message_key.messages
      elsif message_key.is_a?(Array) && message_key.first.is_a?(Hash)
        message = message_key
      else
        message = translate("#{i18n_errors_namespace}.#{message_key}", options)
      end

      message
    end

    NiftyServices::Configuration.response_errors_list.each do |reason_string, status_code|
      define_error_response_method(reason_string, status_code)
    end

    protected
    def not_implemented_exception(method_name)
      raise NotImplementedError, "#{method_name} must be implemented in subclass"
    end

    def translate(key, options = {})
      begin
        I18n.t(key, options)
      rescue => error
        "Can't fecth key #{key} - #{error.message}"
      end
    end
  end
end
