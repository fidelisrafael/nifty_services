module NiftyServices
  module Util
    def normalized_callback_name(callback_name, prefix = '_callback')
      cb_name = callback_name.to_s.gsub(%r(\Z#{prefix}), '')

      [cb_name, prefix].join
    end
    module_function :normalized_callback_name
  end
end
