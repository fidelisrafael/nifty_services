require 'logger'

module NiftyServices
  class Configuration

    DEFAULT_I18N_NAMESPACE = "nifty_services"
    DEFAULT_SERVICE_CONCERN_NAMESPACE = 'NitfyServices::Concerns'

    ERROR_RESPONSE_STATUS = {
      :bad_request           => 400,
      :not_authorized        => 401,
      :forbidden             => 403,
      :not_found             => 404,
      :unprocessable_entity  => 422,
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
        response_errors_list[reason.to_sym] = status_code.to_i
      end
    end

    attr_reader :logger, :options, :i18n_namespace

    attr_accessor :user_class, :service_concerns_namespace

    def initialize(options = {})
      @options = options
      @service_concerns_namespace = default_service_concerns_namespace
      @user_class = options[:user_class] || default_user_class
      @i18n_namespace = @options[:i18n_namespace] || default_i18n_namespace
      @logger = options[:logger] || default_logger
    end

    def default_i18n_namespace
       DEFAULT_I18N_NAMESPACE
    end

    private
    def default_service_concerns_namespace
      DEFAULT_SERVICE_CONCERN_NAMESPACE
    end

    def default_user_class
      nil
    end

    def default_logger
      logger = Logger.new("/dev/null")
      logger.level = Logger::INFO
      logger
    end
  end
end
