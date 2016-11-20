# NiftyServices documentation

---

## Usage

NiftyServices provide a start basic service class for generic code  which is `NiftyServices::BaseService`, the very basic service markup is demonstrated below:

### Basic Service Markup


```ruby
class SemanticServiceName < NiftyServices::BaseService

  def execute
    execute_action do
      success_response if do_something_complex
    end
  end

  def do_something_complex
    # (...) some complex bussiness logic
    return true
  end

  private
  def can_execute?
    return forbidden_error!('errors.message_key') if some_condition

    return not_found_error!('errors.message_key') if another_condition

    return unprocessable_entity_error!('errors.message_key') if other_condition

    # ok, this service can be executed
    return true
  end
end

service = SemanticServiceName.new(options)
service.execute
```

---

### Ok, real world example plizzz

Lets work with a real and a little more complex example, an Service responsible to send daily news mail to users.
The code below shows basically everything you need to know about services structure, such:  entry point, callbacks, authorization, error and success response handling, so after understanding this little piece of code, you will be **ready to code your own services**!

```ruby
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
      success_response if send_mail_to_user
    end
  end

  private
  def can_execute?
    unless valid_user?
      # returns false
      return not_found_error!('users.not_found')
    end

    unless @user.abble_to_receive_daily_news_mail?
      # returns false
      return forbidden_error!('users.already_received_daily_news_mail')
    end

    return true
  end

  def send_mail_to_user
    # just to fake, a real implementation could be something like:
    # @user.send_daily_news_mail!
    return true
  end

  def valid_user?
    # check if object is valid and is a User class type
    valid_object?(@user, User)
  end

  # you can use `default_options` method to add default { keys => values } to @options
  # so you can use the option_enabled?(key) to verify if option is enabled
  # or option_disabled?(key) to verify is option is disabled
  # This default values can be override when creating new instance of Service, eg:
  # DailyNewsMailSendService.new(User.last, validate_api_key: false)
  def default_options
    { validate_api_key: true }
  end
end

class User < Struct.new(:name, :email)
  # just to play around with results
  def abble_to_receive_daily_news_mail?
    rand(10) < 5
  end
end

user = User.new('Rafael Fidelis', 'rafa_fidelis@yahoo.com.br')

# Default logger is NiftyService.config.logger = Logger.new('/dev/null')
service = DailyNewsMailSendService.new(user, logger: Logger.new('daily_news.log'))
service.execute
```

### Sample outputs results

#### :smile: Success:

```
I, [2016-07-15T17:13:40.092854 #2480]  INFO -- : Routine Details: Send daily news email to user
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T17:13:40.092987 #2480]  INFO -- : Routine started at: 2016-07-15 17:13:40 -0300

I, [2016-07-15T17:13:40.093143 #2480]  INFO -- : Success sent daily news feed email to user

I, [2016-07-15T17:13:40.093242 #2480]  INFO -- : Routine ended at: 2016-07-15 17:13:40 -0300


```

#### :weary: Error:

```
I, [2016-07-15T17:12:10.954792 #756]  INFO -- : Routine Details: Send daily news email to user
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T17:12:10.955025 #756]  INFO -- : Routine started at: 2016-07-15 17:12:10 -0300

W, [2016-07-15T17:12:10.955186 #756]  WARN -- : Something went wrong

E, [2016-07-15T17:12:11.019645 #756] ERROR -- : Error sending email to user. See details below :(

E, [2016-07-15T17:12:11.019838 #756] ERROR -- : ["User has already received daily news mail today"]

I, [2016-07-15T17:12:11.020073 #756]  INFO -- : Routine ended at: 2016-07-15 17:12:11 -0300

```

<br />

### Wrapping things up

The code above demonstrate a very basic example of **how dead easy** is to work with Services, let me clarify some things to your better understanding:

* &#9745; All services classes must inherit from `NiftyServices::BaseService`

* &#9745; For convention(but not a rule) all services must expose only `execute`(and of course, `initialize`) as public methods.

* &#9745; `execute_action(&block)` **MUST** be called to properly setup things in execution context.

* &#9745; `can_execute?` must be **ALWAYS** implemented in service classes, **ALWAYS**, this ensure that your code will **safely runned**.
Note: A `NotImplementedError` exception will be raised if service won't define your own `can_execute?` method.

* &#9745; There's a very simple helper functions for marking result as success/fail (eg: `unprocessable_entity_error!` or `success_response`).

* &#9745; Simple DSL for actions callbacks inside current execution context. (eg: `after_success` or `before_error`)
Note: You don't need to use the DSL if you don't want, you can simply define the methods(such as: `private def after_success; do_something; end`

This is the very basic concept of creating and executing a service object, now we need to know how to work with responses to get the most of our services, for this, let's digg in the mainly public API methods of `NiftyService::BaseService` class:


---

### Next

See [Crud Objects API Interface](./api.md)
