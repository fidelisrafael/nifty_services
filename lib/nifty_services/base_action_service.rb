module NiftyServices
  class BaseActionService < BaseService

    def self.action_name(action_name, options={})
      define_method :action_name do
        action_name
      end
    end

    def execute
      execute_action do
        with_before_and_after_callbacks(:action) do
          # here user can
          execute_service_action

          if valid?
            success_response
          else
            errors = action_errors
            bad_request_error(errors) if errors.present?
          end
        end
      end
    end

    private
    def action_errors
      []
    end

    def can_execute?
      unless user_can_execute_action?
        return (valid? ? unprocessable_entity_error!(invalid_action_error_key) : false)
      end

      return true
    end

    def invalid_action_error_key
      "#{record_error_key}.cant_execute_#{action_name}"
    end

    def user_can_execute_action?
      not_implemented_exception(__method__)
    end

    def execute_service_action
      not_implemented_exception(__method__)
    end

    def record_error_key
      not_implemented_exception(__method__)
    end
  end
end
