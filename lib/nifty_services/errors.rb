module NiftyServices
  class Error < Exception
  end

  module Errors
    Configuration::ERROR_RESPONSE_STATUS.each do |error, status|
      class_eval <<-END
        class #{error.to_s.camel_case} < Error
        end
      END
    end
  end
end
