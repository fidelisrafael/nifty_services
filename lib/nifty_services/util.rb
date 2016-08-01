module NiftyServices
  module Util
    def normalized_callback_name(callback_name, suffix = '_callback')
      cb_name = callback_name.to_s.gsub(%r(\Z#{suffix}), '')

      [cb_name, suffix].join
    end
    module_function :normalized_callback_name
  end
end
