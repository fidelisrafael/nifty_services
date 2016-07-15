module NiftyServices
  class BaseActionService < BaseService

    def self.action_name(action_name, options={})
      define_method :action_name do
        action_name
      end
    end

    def execute
      with_before_and_after_callbacks(:action) do
        if can_execute_action?

          execute_action

          if success_runned_action?
            success_response
          else
            errors = action_errors
            bad_request_error(errors) if errors.present?
          end
        end
      end

      success?
    end

    private
    def action_errors
      []
    end

    def can_execute_action?
      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      unless valid_user?
        return not_found_error!('users.not_found')
      end

      unless can_execute?
        if @errors.blank?
          return unprocessable_entity_error!("#{record_error_key}.user_cant_execute_#{action_name}")
        else
          return false
        end
      end

      return true
    end

    def can_execute?
      return false unless valid_user?
      return false unless valid_record?

      user_can_execute_action?
    end

    def success_runned_action?
      not_implemented_exception(__method__)
    end

    def user_can_execute_action?
      not_implemented_exception(__method__)
    end

    def execute_action
      not_implemented_exception(__method__)
    end

    def valid_record?
      not_implemented_exception(__method__)
    end

    def record_error_key
      not_implemented_exception(__method__)
    end
  end
end
