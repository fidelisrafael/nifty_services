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
          with_before_and_after_callbacks(:execute_service_action) do
            execute_service_action
          end

          success_response if valid?
        end
      end
    end

    private
    def action_errors
      @errors
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

    def action_name
      not_implemented_exception(__method__)
    end
  end
end
