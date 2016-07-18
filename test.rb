class DailyNewsMailSendService < NiftyServices::BaseService

  before_execute do
    log.info('Routine started at: %s' % Time.now)
  end

  after_execute do
    log.info('Routine ended at: %s' % Time.now)
  end

  after_initialize do
    user_data = [@user.name, @user.email]
    log.info('Routine Details: Send daily news email to user %s(%s)' % user_data)
  end

  after_success do
    log.info('Success sent daily news feed email to user')
  end

  before_error do
    log.warn('Something went wrong')
  end

  after_error do
    log.error('Error sending email to user. See details below :(')
    log.error(errors)
  end

  attr_reader :user

  def initialize(user, options = {})
    @user = user
    super(options)
  end

  def execute
    execute_action do
      if can_execute?
        success_response if send_mail_to_user
      end
    end
  end

  private
  def send_mail_to_user
    # just to fake, a real implementation could be something like:
    # @user.send_daily_news_mail!
    return true
  end

  def can_execute?
    unless valid_user?
      # returns false
      return not_found_error!('users.not_found')
    end

    unless @user.abble_to_receive_daily_news_mail?
      # returns false
      return forbidden_error!('users.yet_received_daily_news_mail')
    end

    return true
  end

  def valid_user?
    # check if object is valid and is a User class type
    valid_object?(@user, User)
  end
end

class User < Struct.new(:name, :email)
  # just to play around with results
  def abble_to_receive_daily_news_mail?
    rand(10) < 5
  end
end

user = User.new('Rafael Fidelis', 'rafa_fidelis@yahoo.com.br')

# Default logger is NiftyService.config.logger # Logger.new('/dev/null')
service = DailyNewsMailSendService.new(user, logger: Logger.new('daily_news.log'))
service.execute
