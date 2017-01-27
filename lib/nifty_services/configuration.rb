module NiftyServices
  class Configuration

    DEFAULT_I18N_NAMESPACE = "nifty_services"

    ERROR_RESPONSE_STATUS = {
      :bad_request           => 400,
      :not_authorized        => 401,
      :forbidden             => 403,
      :not_found             => 404,
      :unprocessable_entity  => 422,
      # internal_server_error_error!
      :internal_server_error => 500,
      # keeping compatibility
      # internal_server_error!
      :internal_server       => 500,
      :not_implemented       => 501
    }

    SUCCESS_RESPONSE_STATUS = {
      :ok => 200,
      :created => 201
    }

    class << self
      def response_errors_list
        ERROR_RESPONSE_STATUS
      end

      def add_response_error_method(reason, status_code)
        ERROR_RESPONSE_STATUS[reason.to_sym] = status_code.to_i
      end
    end

    attr_reader :options

    attr_accessor :logger, :i18n_namespace,
                  :delete_record_method, :update_record_method, :save_record_method

    def initialize(options = {})
      @options = options
      @i18n_namespace = fetch(:i18n_namespace, default_i18n_namespace)
      @delete_record_method = :delete
      @update_record_method = :update
      @save_record_method = :save
      @logger = fetch(:logger, default_logger)
    end

    private
    def fetch(option_key, default = nil)
      @options[option_key] || default
    end

    def default_i18n_namespace
       DEFAULT_I18N_NAMESPACE
    end

    def default_logger
      logger = Logger.new("/dev/null")
      logger.level = Logger::INFO
      logger
    end
  end
end
