module NiftyServices
  class BaseDeleteService < BaseCrudService

    def execute
      execute_action do
        with_before_and_after_callbacks(:delete) do
          if can_execute_action?
            deleted_record = with_before_and_after_callbacks(:delete_record) { delete_record }

            if deleted_record
              success_response
            else
              unprocessable_entity_error!(@record.errors)
            end
          end
        end
      end
    end

    private
    def delete_record
      delete_method = NiftyServices.configuration.delete_record_method

      if delete_method.respond_to?(:call)
        delete_method.call(@record)
      else
        @record.public_send(delete_method)
      end

      # initialize @temp_record to be used in after_delete_record callback
      @temp_record = @record
    end

    def can_execute?
      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      return true
    end

    def can_delete_record?
      not_implemented_exception(__method__)
    end

    def can_execute_action?
      unless can_delete_record?
        return (valid? ? forbidden_error!(cant_delete_error_key) : false)
      end

      return true
    end

    def cant_delete_error_key
      "#{record_error_key}.cant_delete"
    end
  end
end
