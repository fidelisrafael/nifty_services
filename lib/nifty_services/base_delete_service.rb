module NiftyServices
  class BaseDeleteService < BaseCrudService

    def execute
      execute_action do
        with_before_and_after_callbacks(:delete) do
          if can_execute_action?
            destroyed_record = with_before_and_after_callbacks(:destroy_record) { destroy_record }

            if destroyed_record
              success_response
            else
              unprocessable_entity_error!(@record.errors)
            end
          end
        end
      end
    end

    private
    def destroy_record
      # initialize @temp_record to be used in after_destroy_record callback
      @temp_record = @record.destroy
    end

    def can_execute?
      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      if validate_user? && !valid_user?
        return not_found_error!(invalid_user_error_key)
      end

      return true
    end

    def can_delete_record?
      unless user_can_delete_record?
        return (valid? ? forbidden_error!(user_cant_delete_error_key) : false)
      end

      return true
    end

    def can_execute_action?
      return can_delete_record?
    end

    def user_can_delete_record?
      return not_implemented_exception(__method__) unless @record.respond_to?(:user_can_delete?)

      @record.user_can_delete?(@user)
    end

    def user_cant_delete_error_key
      "#{record_error_key}.user_cant_delete"
    end
  end
end
