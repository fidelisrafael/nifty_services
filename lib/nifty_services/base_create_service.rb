module NiftyServices
  class BaseCreateService < BaseCrudService

    def initialize(options = {})
      super(nil, options)
    end

    def execute
      execute_action do
        with_before_and_after_callbacks(:create) do
          if can_execute_action?
            @record = with_before_and_after_callbacks(:build_record) { build_record }

            if try_to_save_record
              after_execute_success_response
            else
              on_record_create_failed(@record)
            end
          end
        end
      end
    end

    def success_created?
      valid?
    end

    private
    def can_create_record?
      not_implemented_exception(__method__)
    end

    def on_save_record_error(error)
      raise_record_error_exception(__method__, error)
    end

    def on_record_create_failed(record)
      unprocessable_entity_error!(create_errors(record)) if @errors.empty?
    end

    def try_to_save_record
      throw_exception = false

      begin
        save_record
      rescue => e
        throw_exception = true
      ensure
        on_save_record_error(e) if throw_exception

        return success_created?
      end
    end

    def save_record
      save_method = NiftyServices.configuration.save_record_method

      return save_method.call(@record) if save_method.respond_to?(:call)

      @record.public_send(save_method)
    end

    def after_execute_success_response
      success_created_response
    end

    def build_record
      unless record_type.nil?
        # initialize @temp_record to be used in after_build_record callback
        return @temp_record = build_from_record_type(record_allowed_attributes)
      end

      @temp_record = record_type.public_send(:new, record_allowed_attributes)
    end

    def build_record_scope
      nil
    end

    def build_from_record_type(attributes)
      scope = record_type

      if !build_record_scope.nil? && build_record_scope.respond_to?(:new)
        scope = build_record_scope
      end

      scope.new(attributes)
    end

    def can_execute?
      return true
    end

    def can_execute_action?
      unless can_create_record?
        return (valid? ? forbidden_error!(cant_create_error_key) : false)
      end

      return true
    end

    def create_errors(record)
      record.errors
    end

    def cant_create_error_key
      "#{record_error_key}.cant_create"
    end
  end
end
