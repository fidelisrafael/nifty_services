module NiftyServices
  module Util
    def normalized_callback_name(callback_name, suffix = '_callback')
      cb_name = callback_name.to_s.end_with?(suffix) ?
                  callback_name.to_s.sub(/#{suffix}\Z/, '') :
                  callback_name.to_s

      cb_name << suffix
    end
    module_function :normalized_callback_name
  end
end
