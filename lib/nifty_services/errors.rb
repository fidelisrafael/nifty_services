module NiftyServices
  class Error < Exception
  end

  module Errors
    BaseService::ERROR_RESPONSE_METHODS.each do |error, status|
      class_eval <<-END
        class #{error.to_s.camelize} < Error
        end
      END
    end
  end
end
