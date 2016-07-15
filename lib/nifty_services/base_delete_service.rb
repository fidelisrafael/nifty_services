module NiftyServices
  class BaseDeleteService < BaseCrudService

    def execute
      with_before_and_after_callbacks(:delete) do
        if can_execute_action?
          if destroy_record
            success_response
          else
            bad_request_error(@record.errors)
          end
        end
      end

      success?
    end

    private
    def destroy_record
      @record.destroy
    end

    def can_execute_action?
      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      unless valid_user?
        return not_found_error!('users.not_found')
      end

      unless can_delete?
        return forbidden_error!("#{record_error_key}.user_cant_delete")
      end

      return true
    end

    def can_delete?
      return false unless valid_user?
      return false unless valid_record?

      return user_can_delete_record?
    end

    def user_can_delete_record?
      @record.user_can_delete?(@user)
    end
  end
end
