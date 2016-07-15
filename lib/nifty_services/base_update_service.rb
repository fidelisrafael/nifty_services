module NiftyServices
  class BaseUpdateService < BaseCrudService

    def execute
      with_before_and_after_callbacks(:update) do
        if can_execute_action?
          @updated_record = update_record
          @updated_record ||= @record

          if success_updated?
            success_response
          else
            errors = update_errors
            bad_request_error(errors) if errors.present?
          end
        end
      end

      success?
    end

    def changed_attributes
      return [] if fail?
      @changed_attributes ||= changes(@old_record, @record, changed_attributes_array)
    end

    private

    def changed_attributes_array
      record_params.keys
    end

    def success_updated?
      @updated_record.valid?
    end

    def update_errors
      @updated_record.errors
    end

    def update_record
      @record.class.send(:update, @record.id, record_params)
    end

    def can_execute_action?

      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      unless valid_user?
        return not_found_error!('users.not_found')
      end

      unless can_update?
        return forbidden_error!("#{record_error_key}.user_cant_update")
      end

      return true
    end

    def can_update?
      return false unless valid_user?
      return false unless valid_record?

      return user_can_update_record?
    end

    def user_can_update_record?
      @record.user_can_update?(@user)
    end

    def after_success
      @old_record = @record.dup
      @record     = @updated_record
    end
  end
end
