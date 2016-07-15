module NiftyServices
  class BaseCreateService < BaseCrudService

    def initialize(user, options = {})
      @user = user
      super(nil, user, options)
    end

    def execute
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

      success?
    end

    private
    def save_record
      @record.save
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
      _record_params = record_allowed_params

      if record_type.present? && _record_params.present?
        return build_from_record_type(_record_params)
      end

      return not_implemented_exception(__method__)
    end

    def build_from_record_type(record_params)
      record_type.send(:new, record_params)
    end

    def can_execute_action?
      if validate_ip_on_create? && !can_create_with_ip?
        return forbidden_error!(%s(users.ip_temporarily_blocked))
      end

      unless valid_user?
        return not_found_error!(%s(users.not_found))
      end

      unless can_create?
        if @errors.blank?
          return forbidden_error!("#{record_error_key}.user_cant_create")
        else
          return false
        end
      end

      return valid?
    end

    def can_create?
      return false unless valid_user?

      return user_can_create_record?
    end

    def can_create_with_ip?
      true
    end

    def validate_ip_on_create?
      # TODO: Use NiftyService.config.validate_ip_on_create?
      false
    end

    def user_can_create_record?
      not_implemented_exception(__method__)
    end
  end
end
