require 'nifty_services/version'
require 'active_support/core_ext/string/inflections'

module NiftyServices

  autoload :BaseService,        'nifty_services/base_service'
  autoload :BaseActionService,  'nifty_services/base_action_service'
  autoload :BaseCrudService,    'nifty_services/base_crud_service'
  autoload :BaseCreateService,  'nifty_services/base_create_service'
  autoload :BaseDeleteService,  'nifty_services/base_delete_service'
  autoload :BaseUpdateService,  'nifty_services/base_update_service'
  autoload :Configuration,      'nifty_services/configuration'
  autoload :Error,              'nifty_services/errors'
  autoload :Errors,             'nifty_services/errors'
  autoload :Util,               'nifty_services/util'
  autoload :Hash,               'nifty_services/support/hash'

  module Extensions
    autoload :CallbacksInterface, 'nifty_services/extensions/callbacks_interface'
  end

  class << self
    def configuration(&block)
      @configuration ||= Configuration.new

      yield(@configuration) if block_given?

      @configuration
    end

    alias :config :configuration
  end
end
