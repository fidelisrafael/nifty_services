# NiftyServices

Nifty Services come to solve your Ruby applications(*including but not limited to* Rails, Grape, Sinatra, and plain Ruby) code mess with **simplicity in mind**!

NiftyServices provider a very simple and clear API to **organize and reuse** your application **domain logic in plain Ruby Services Objects** turning your codebase in a very extensible, standardized and reusable components.

**Most important:** You and your team win what I consider the best benefit when using Nifty Services: **Easily and scalable maintained code.**
 Believe me, you'll fall in love with this small piece of code, keep reading!

This gem was designed and conventioned to be used specially with **Web API applications**, but this is just a convention, you can use it's even with [shoes (for desktop apps)](https://github.com/shoes/shoes) applications if you  want, for example.

#### I know, this README is very huge

As you can see, this README is a very long read, but is very difficulty to explain all things, concepts and philosophy of this gem without writing a lot, we can't escape this :( 
But remember one thing: This is a **tecnical documentation**, not a blog post, I'm pretty sure you can take 1 or 2 hours to better understand all NiftyServices can do for you and your project. Good reading, and if you have some question, [please let me know](/issues/new).

---

## Conventions

Below, some very importants things about conventions for this cute gem :)

### Single responsibility

Each service class is responsible for perform exactly [one single task](https://en.wikipedia.org/wiki/Single_responsibility_principle), say goodbye for code (most important: logic) duplication in your code.
Beside this, one of the aim of NiftyServices is to provide a **very standardized** code architecture, allowing developers to quickly develop and implement new features keeping the application codebase organized and stable.

### Common execution method

Each service object must respond to `#execute` instance method, which is allowed to be **called just one time** per instance.
`#execute` method is responsible to perform code validation(parameter validation, access level control), execution(send mail, register users) and fire callbacks so you can execute hooks actions **after/before success or execution fail**.

### Rich Service Objects

When dealing with services objects, you will get a very rich objects to work with, forgot about getting only `true or false` return values, one of the main purpose of objects it's to keep your code domain logic accessible and reusable, so your application can really take the best approach when responding to actions.

### Security - Access Control Level

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

    return unprocessable_entity_error('errors.message_key') if other_condition

    # ok, this service can be executed
    return true
  end
end

service = SemanticServiceName.new(options)
service.execute
```

---

### Ok, real world example plizzz

Lets work with a real and a little more complex example, an Service responsible to send daily news mail to users:

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
      return forbidden_error!('users.yet_received_daily_news_mail')
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

#### Sample outputs

**Success:**

```
I, [2016-07-15T17:13:40.092854 #2480]  INFO -- : Routine Details: Send daily news email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T17:13:40.092987 #2480]  INFO -- : Routine started at: 2016-07-15 17:13:40 -0300

I, [2016-07-15T17:13:40.093143 #2480]  INFO -- : Success sent daily news feed email to user

I, [2016-07-15T17:13:40.093242 #2480]  INFO -- : Routine ended at: 2016-07-15 17:13:40 -0300


```

**Error:**

```
I, [2016-07-15T17:12:10.954792 #756]  INFO -- : Routine Details: Send daily news email to user 
Rafael Fidelis(rafa_fidelis@yahoo.com.br)

I, [2016-07-15T17:12:10.955025 #756]  INFO -- : Routine started at: 2016-07-15 17:12:10 -0300

W, [2016-07-15T17:12:10.955186 #756]  WARN -- : Something went wrong

E, [2016-07-15T17:12:11.019645 #756] ERROR -- : Error sending email to user. See details below :(

E, [2016-07-15T17:12:11.019838 #756] ERROR -- : ["User yet received daily news mail today"]

I, [2016-07-15T17:12:11.020073 #756]  INFO -- : Routine ended at: 2016-07-15 17:12:11 -0300

```

<br />

### Wrapping things up

The code above demonstrate a very basic example of **how dead easy** is working with Services, let me clarify some things to your better understanding:

* All services classes must inherit from `NiftyServices::BaseService`

* For convention(but not a rule) all services must expose only `execute`(and of course, `initialize`) as public methods.

* `execute_action(&block)` **MUST** be called to properly setup things in execution context.

* `can_execute?` must be **ALWAYS** implemented in service classes, **ALWAYS**, this ensure that your code will **safely runned**.
Note: A `NotImplementedError` exception will be raised if service won't define your own `can_execute?` method.

* There's a very simple DSL for marking result as success/fail (eg: `unprocessable_entity_error!` or `success_response`).

* Simple DSL for actions callbacks inside current execution context. (eg: `after_success` or `before_error`) 
Note: You don't need to use the DSL if you don't want, you can simply define the methods(such as: `private def after_success; do_something; end`

This is the very basic concept of creating and executing a service object, now we need to know how to work with responses to get the most of our services, for this, let's digg in the mainly public API methods of `NiftyService::BaseService` class:

---

## Services Public API 

Below, a list of most common public accessible methods for any instance of service:
(Detailed usage and full API list is available below this section)

```ruby
service.success? # boolean
service.fail? # boolean
service.errors # array
service.response_status # symbol (eg: :ok)
service.response_status_code # integer (eg: 200)
```

So, grabbing our `DailyNewsMailSendService` service again, we could do:

```ruby
service = DailyNewsMailSendService.new(User.new('test', 'test@test.com'))
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

## CRUD Services

So, until now we saw how to use `NiftyServices::BaseService` to create generic services to couple specific domain logic for actions,  this is very usefull, but things get a lot better when you're working with **CRUD** actions for your api.

---

### I18n Support


[TODO]

---

## Handling Success

To mark a service running as successfully, you must call one of this methods:

* `success_response # [200, :ok]`
* `success_created_response [201, :created]`

The first value in comments above is the value which will be defined to `service.response_status_code` and the last is the value set to `service.response_status`.

---


## Handling Error  

By default, all services comes with following error methods:
(**Hint**: See all available error methods [`here`](lib/nifty_services/configuration.rb#L10-16))

```ruby
bad_request_error(message_key) # set response_status_code to 400

not_authorized_error(message_key) # set response_status_code to 401,

forbidden_error(message_key) # set response_status_code to 403,

not_found_error(message_key) # set response_status_code to 404,

unprocessable_entity_error(message_key) # set response_status_code to 422,

internal_server_error(message_key) # set response_status_code to 500,

not_implemented_error(message_key) # set response_status_code to 501
```

Beside this methods, you can always use **low level** API to generate errors, just call the `error` method, ex:

```
# API
error(status, message_key, options = {})

# eg:
error(409, :conflict_error, reason: 'unkown')
error!(409, :conflict_error, reason: 'unkown')

# suppose you YML locale file have the configuration:
# nifty_services:
#  errors:
#    conflict_error: 'Conflict! The reason is %{reason}'
```

#### Custom error response methods

But you can always add new convenience errors methods via API, this way you gain more expressivity and sintax sugar:

```ruby
## API
NiftyServices.add_response_error_method(status, status_code)

## eg: 

NiftyServices.add_response_error(:conflict, 409)

## now you gain the methods:

## conflict_error(:conflict_error)
## conflit_error!(:conflict_error)
``` 

---

## Callbacks

Here the most common callbacks list you can use to hook actions in run-time:
(**Hint**: See all existent callbacks definitions in [`extensions/callbacks_interface.rb`](lib/nifty_services/extensions/callbacks_interface.rb#L8-L24) file)


- before_initialize
- after_initialize
- before_execute
- after_execute
- before_error
- after_error
- before_success
- after_success

---

## Configuration

There are only a few things you must want and have to configure for your services work properly, below you can see all needed configuration:

```ruby
NiftyServices.config do |config|  
  # [optional - but very recommend! Please, do it]
  # class used to control ACL 
  config.user_class = User
  
  # [optional]
  # global logger for all services
  # [Default: Logger.new('/dev/null')]
  config.logger = Logger.new('log/services_logger.log')
  
  # [optional]
  # Namespace to lookup when using concerns with services
  # [Default: 'NitfyServices::Concerns']
  config.service_concerns_namespace = "Services::V1::Concerns"

end
```

---

## Web Frameworks Integrations

#### Rails

You need a very minimal setup to integrate

#### Grape/Sinatra/Padrino/Hanami

[TODO]

---

## Full Public API methods list

You can use any of the methods above with your `services instances`:

```ruby
service.success? # boolean
service.fail? # boolean

service.errors # hash
service.add_error(error) # array

service.response_status # symbol (eg: :ok)
service.response_status_code # integer (eg: 200)

service.changed_attributes # array
service.changed? # boolean

service.callback_fired?(callback_name) # boolean
service.register_callback(name, method, &block) # nil
service.register_callback_action(&block) # nil

service.option_exists?(option_name) # boolean
service.option_enabled?(option_name) # boolean
service.option_disabled?(option_name) # boolean
```

---

## Generators

Currently NiftyServices don't have CLI generators, but is in the roadmap, so keep your eyes here!

---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/simple_services. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
