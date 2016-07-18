module NiftyServices
  class BaseCreateService < BaseCrudService

    def initialize(user, options = {})
      @user = user
      super(nil, user, options)
    end

    def execute
      execute_action do
        with_before_and_after_callbacks(:create) do
          if can_execute_action?
            @record = build_record

            if save_record
              after_execute_success_response
            else
              errors = create_error_response(@record)
              after_error_response(errors)
            end
          end
        end
      end
    end

    private
    def save_record
      begin
        @record.save
      rescue => e
        on_save_record_error(e)
        return false
      end
    end

    def on_save_record_error(error)
      return unprocessable_entity_error!(error)
    end

    def create_error_response(record)
      record.errors
    end

    def after_error_response(errors)
      unprocessable_entity_error(errors) if errors.present?
    end

    def after_execute_success_response
      success_created_response
    end

    def after_success
    end

    def build_record
      if record_type.present?
        return build_from_record_type(record_allowed_attributes)
      end

      return not_implemented_exception(__method__)
    end

    def build_from_record_type(params)
      if !build_record_scope.nil? && build_record_scope.respond_to?(:build)
        return build_record_scope.send(:build, params)
      end

      record_type.send(:new, params)
    end

    def can_execute?
      if validate_ip_on_create? && !can_create_with_ip?
        return forbidden_error!(%s(users.ip_temporarily_blocked))
      end

      if validate_user? && !valid_user?
        return not_found_error!(invalid_user_error_key)
      end

      return true
    end

    def can_create_record?
      unless user_can_create_record?
        return (valid? ? forbidden_error!(user_cant_create_error_key) : false)
      end

      return true
    end

    def user_can_create_record?
      not_implemented_exception(__method__)
    end

    def can_execute_action?
      return can_create_record?
    end

    def can_create_with_ip?
      true
    end

    def validate_ip_on_create?
      # TODO: Use NiftyService.config.validate_ip_on_create?
      false
    end

    def build_record_scope
      nil
    end

    def user_cant_create_error_key
      "#{record_error_key}.user_cant_create"
    end
  end
end
