module NiftyServices
  module Util
    module_function
    def normalized_callback_name(callback_name, prefix = '_callback')
      cb_name = callback_name.to_s.gsub(%r(\Z#{prefix}), '')

      [cb_name, prefix].join
    end
  end
end
