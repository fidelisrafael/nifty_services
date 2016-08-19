module NiftyServices
  class BaseUpdateService < BaseCrudService

    def execute
      execute_action do
        with_before_and_after_callbacks(:update) do
          if can_execute_action?
            duplicate_records_before_update

            @record = with_before_and_after_callbacks(:update_record) { update_record }

            if success_updated?
              success_response
            else
              errors = update_errors
              unprocessable_entity_error!(errors) unless errors.empty?
            end
          end
        end
      end
    end

    def changed_attributes
      return [] if fail?
      @changed_attributes ||= changes(@last_record, @record, changed_attributes_array)
    end

    private

    def changed_attributes_array
      record_allowed_attributes.keys
    end

    def success_updated?
      @record.valid?
    end

    def update_errors
      @record.errors
    end

    def update_record
      # initialize @temp_record to be used in after_update_record callback
      @temp_record = @record.class.send(:update, @record.id, record_allowed_attributes)
    end

    def can_execute?
      unless valid_record?
        return not_found_error!(invalid_record_error_key)
      end

      if validate_user? && !valid_user?
        return not_found_error!(invalid_user_error_key)
      end

      return true
    end

    def can_update_record?
      unless user_can_update_record?
        return (valid? ? forbidden_error!(user_cant_update_error_key) : false)
      end

      return true
    end

    def can_execute_action?
      return can_update_record?
    end

    def user_can_update_record?
      return not_implemented_exception(__method__) unless @record.respond_to?(:user_can_update?)

      @record.user_can_update?(@user)
    end

    def duplicate_records_before_update
      @last_record = @record.dup
    end

    def invalid_record_error_key
      "#{record_error_key}.not_found"
    end

    def user_cant_update_error_key
      "#{record_error_key}.user_cant_update"
    end

  end
end
