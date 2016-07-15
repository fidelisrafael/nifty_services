# NiftyServices

Nifty Services come to solve your Ruby applications(*including but not limited to* Rails, Grape, Sinatra, and plain Ruby) code mess with **simplicity in mind**!

NiftyServices provider a very simple and clear API to **organize and reuse** your application **domain logic in plain Ruby Services Objects** turning your codebase in a very extensible, standardized and reusable components.

**Most important:** You and your team win what I consider the best benefit when using Nifty Services: **Easily and scalable maintained code.**
 Believe me, you'll fall in love with this small piece of code, keep reading!

This gem was designed and conventioned to be used specially with **Web API applications**, but this is just a convention, you can use it's even with [shoes](https://github.com/shoes/shoes) applications if you 

### Conventions

#### Single responsibility

Each service class is responsible for perform exactly [one single task](https://en.wikipedia.org/wiki/Single_responsibility_principle), say goodbye for code (most important: logic) duplication in your code.
Beside this, one of the aim of NiftyServices is to provide a **very standardized** code architecture, allowing developers to quickly develop and implement new features keeping the application codebase organized and stable.

#### Common execution method

Each service object must respond to `#execute` instance method, which is allowed to be **called just one time** per instance.
`#execute` method is responsible to perform code validation(parameter validation, access level control), execution(send mail, register users) and fire callbacks so you can execute hooks actions **after/before success or execution fail**.

#### Rich Service Objects

When dealing with services objects, you will get a very rich objects to work with, forgot about getting only `true or false` return values, one of the main purpose of objects it's to keep your code domain logic accessible and reusable, so your application can really take the best approach when responding to actions.

#### Security - Access Control Level

Think and implement security rules from the first minutes of live in your applications! NiftyServices strongly rely on **Access Control Level(ACL)** to perform actions, in other words, you will only **allow authorized users to read, create, update or delete records in your database**!

Now you know the basic concepts and philosophy of `NiftyServices`, lets start working with this candy library?

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nifty_services'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nifty_services

## Usage

NiftyServices provide a start basic service class for generic code  which is `NiftyServices::BaseService`, the very basic service structure is demonstrated below:

```ruby
class User < Struct.new(:name, :email)
  # just to play around with results
  def received_welcome_mailer?
    rand(10) < 5
  end
end

class WelcomeMailSendService < NiftyServices::BaseService

  attr_reader :user

  before_execute do
    log.info('Routine started at: %s' % Time.now)
  end

  after_execute do
    log.info('Routine ended at: %s' % Time.now)
  end

  after_initialize do
    user_data = [@user.name, @user.email, Time.now]
    log.info('Routine details: Send welcome email to user %s(%s) at %s' % user_data)
  end

  after_success do
    user_data = [@user.name, @user.email]
    log.info('success sent welcome email to user %s(%s)' % user_data)
  end

  before_error do
    log.warn('something went wrong :(')
  end

  after_error do
    user_data = [@user.name, @user.email]
    log.error('error sending welcome email to user %s(%s)' % user_data)
    log.error(errors)
  end

  def initialize(user, options = {})
    @user = user
    super(options)
  end

  def execute
    execute_action do
      if can_execute_action?
        return success_response if send_mail_to_user
      end
    end
  end

  private
  def send_mail_to_user
    return true # just to fake
    # UsersMailer.welcome(@user).deliver
  end

  def can_execute_action?
    unless valid_user?
      # returna false value
      return not_found_error!('users.not_found')
    end

    if @user.received_welcome_mailer?
      # returns false
      return unprocessable_entity_error!('users.yet_received_welcome_mailer')
    end

    # remember to always return this
    return true
  end

  def valid_user?
    # check if object is valid and is a User class type
    valid_object?(@user, User)
  end
end

user = User.new('Rafael Fidelis', 'rafa_fidelis@yahoo.com.br')
service = WelcomeMailSendService.new(user)
service.execute
```

#### Sample outputs

**Success:**

```
I, [2016-07-15T12:42:56.780943 #25358]  INFO -- : Routine details: Send welcome email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T12:42:56.781087 #25358]  INFO -- : Routine started at: 2016-07-15 12:42:56 -0300

I, [2016-07-15T12:42:56.781244 #25358]  INFO -- : Success sent welcome email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T12:42:56.781343 #25358]  INFO -- : Routine ended at: 2016-07-15 12:42:56 -0300

```

**Error:**

```
I, [2016-07-15T12:43:58.060858 #26371]  INFO -- : Routine details: Send welcome email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T12:43:58.060994 #26371]  INFO -- : Routine started at: 2016-07-15 12:43:58 -0300

W, [2016-07-15T12:43:58.061094 #26371]  WARN -- : Something went wrong :(

E, [2016-07-15T12:43:58.092449 #26371] ERROR -- : Error sending welcome email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br). Details below

E, [2016-07-15T12:43:58.092539 #26371] ERROR -- : ["User yet received welcome mail"]

I, [2016-07-15T12:43:58.092678 #26371]  INFO -- : Routine ended at: 2016-07-15 12:43:58 -0300

```

<br />

This is a very basic example of how simple is working with services, let me clairify some things to better understanding:

* All services classes must inherit from **NiftyServices::BaseService**
* For convention(but not a rule) all services must expose only `execute`(and of course, `initialize`) as public methods.
* `execute_action(&block)` **MUST** be called to properly setup things in execution context.
* Execution authorization can be **always** validated through methods.
* There's a very simple DSL for marking result as success/fail (eg: `unprocessable_entity_error!` or `success_response`).
* Simple DSL for actions callbacks inside current execution context. (eg: `after_success` or `before_error`) 

This is the very basic concept of creating and executing a service object, now we need to know how to work with responses to get the most of our services, for this, let's digg in the mainly public API methods of `NiftyService::BaseService` class:

---

### Services Public API 

Below, a list of most common public accessible methods for any instance of service:
(Detailed usage and descriptions below this section)

```ruby
service.success? # boolean
service.fail? # boolean
service.errors # hash
service.response_status # symbol (eg: :ok)
service.response_status_code # integer (eg: 200)
```

So, grabbing our `SendWelcomeMailer` service again, we could do:

```ruby
service = WelcomeMailSendService.new(User.new('test', 'test@test.com'))
service.execute

if service.success? # or unless service.fail?
  SentEmails.create(user: service.user, type: 'welcome_email')
else
  puts 'Error sending email, details below:'
  puts 'Status: %s' % service.response_status
  puts 'Status code: %s' % service.response_status_code
  puts service.errors
end

# trying to re-execute the service will return `nil`
service.execute
```

This is really great and nifty, no? But we already started, there's some really cool stuff when dealing with **Restful** API's, let's see.

---

### CRUD Services

So, until now we saw how to use `NiftyServices::BaseService` to create generic services to couple specific domain logic for actions,  this is very usefull, but things get a lot better when you're working with **CRUD** actions for your api.

---

### I18n Support


[TODO]

---

### Configuration

```ruby
NiftyServices.config do |config|
  config.service_concerns_namespace = "Services::V1::Concerns"
  config.user_class = User
  config.logger = Logger.new('STOUD')
end
```

---

[TODO]

### Generators

[TODO]

---

#### Full Public API methods list

You can use any of the methods above with your `services instances`:

```ruby
service.success? # boolean
service.fail? # boolean
service.errors # hash
service.response_status # symbol (eg: :ok)
service.response_status_code # integer (eg: 200)
service.changed_attributes # array
service.changed? # boolean
service.callback_fired?(callback_name) # boolean
service.option_exists?(option_name) # boolean
service.option_enabled?(option_name) # boolean
service.option_disabled?(option_name) # boolean
service.register_callback(name, method, &block) # nil
service.register_callback_action(&block) # nil
service.add_error(error) # array
```

---

### Error methods

[TODO  - Better explanation]

```ruby
bad_request_error(message_key) # set response_status_code to 400,

not_authorized_error(message_key) # set response_status_code to 401,

forbidden_error(message_key) # set response_status_code to 403,

not_found_error(message_key) # set response_status_code to 404,

unprocessable_entity_error(message_key) # set response_status_code to 422,

internal_server_error(message_key) # set response_status_code to 500,

not_implemented_error(message_key) # set response_status_code to 501
```

Adding new error methods:

```ruby
## API
NiftyServices.add_response_error_method(status, status_code)

## eg: 
NiftyServices.add_response_error(:conflict, 409)

## now you gain the methods:

## conflict_error(message_key)
## conflit_error!(message_key)
``` 

---

### Callbacks List

Here the callbacks list you can use to hook actions in run-time:

- before_initialize
- after_initialize
- before_execute
- after_execute
- before_error
- after_error
- before_success
- after_success
- before_create
- after_create
- before_update
- after_update
- before_delete
- after_delete
- before_action
- after_action

### Web Frameworks Integrations

#### Rails

[TODO]

#### Grape/Sinatra/Padrino/Hanami

[TODO]


---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simple_services. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
