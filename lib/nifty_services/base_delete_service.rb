module NiftyServices
  class BaseDeleteService < BaseCrudService

    def execute
      execute_action do
        with_before_and_after_callbacks(:delete) do
          if can_execute_action?
            with_before_and_after_callbacks(:delete_record) { try_to_delete_record }

            if success_deleted?
              success_response
            else
              on_record_delete_failed(@record)
            end
          end
        end
      end
    end

    def success_deleted?
      valid?
    end

    private

    def can_delete_record?
      not_implemented_exception(__method__)
    end

    def on_delete_record_error(error)
      raise_record_error_exception(__method__, error)
    end

    def on_record_delete_failed(record)
      unprocessable_entity_error!(delete_errors(record)) if @errors.empty?
    end

    def try_to_delete_record
      throw_exception = false
      begin
        delete_record
      rescue => e
        throw_exception = true
      ensure
        on_delete_record_error(e) if throw_exception

        return success_deleted?
      end
    end

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

    def can_execute_action?
      unless can_delete_record?
        return (valid? ? forbidden_error!(cant_delete_error_key) : false)
      end

      return true
    end

    def can_execute?
      unless valid_record?
        return not_found_error!("#{record_error_key}.not_found")
      end

      return true
    end

    def delete_errors(record)
      record.errors
    end

    def cant_delete_error_key
      "#{record_error_key}.cant_delete"
    end
  end
end
