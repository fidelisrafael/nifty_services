# NiftyServices 

## Introduction

Nifty Services comes to solve your Ruby applications(*including but not limited to* Rails, Grape, Sinatra, and plain Ruby) code mess with **simplicity in mind**!

NiftyServices provider a very nifty, simple & clear API to **organize and reuse** your application **domain logic in plain Ruby Services Objects** turning your codebase in a very extensible, standardized and reusable components.

**Most important:** You and your team win what I consider the best benefit when using Nifty Services: **Easily and scalable maintained code.**  
 Believe me, you'll fall in :heart_eyes: with this small piece of code, keep reading!

This gem was designed and conventioned to be used specially with **Web API applications**, but this is just a convention, you can use it's even with [shoes (for desktop apps)](https://github.com/shoes/shoes) applications if you  want, for example.

#### :book: I know, this README is very huge

As you can see, this README needs some time to be full read, but is very difficulty to explain all things, concepts and philosophy of this gem without writing a lot, we can't escape this :(   

But remember one thing: This is a **tecnical documentation**, not a blog post, I'm pretty sure you can take 1 or 2 hours + :coffee: to better understand all NiftyServices can do for you and your project. Good reading, and if you have some question, [please let me know](/issues/new).

---

## Table of Contents

* [Dafuck is this gem](#introduction)
* [Conventions](#conventions)
  * [Single Responsability](#conventions-single-responsibility)
  * [Method execution](#hammer-common-and-single-run-execution-method)
  * [Rich Service Objects](#package-rich-service-objects)
  * [Security & Access Level Control](#lock-security---access-control-level)
* [Installation](#installation)
* [Usage](#usage) 
  * [Basic Service Markup](#basic-service-markup) 
  * [How a Service must be created](#wrapping-things-up)
  * [Services API](#services-public-api)
    * [Full Public Service API Methods List](#full-public-api-methods-list)
  * [Handling Success & Error Responses](#success--error-responses)
    * [Success response](#white_check_mark-handling-success-zap)
    * [Error response](#red_circle-handling-error-boom)
      * [Custom error response methods](#custom-error-response-methods)
  * [CRUD Services](#crud-services)
    * [**Create** - BaseCreateService](#white_check_mark-crud-create)
      * [I18n Setup](#earth_americas-i18n-setup)
      * [Error - Invalid User](#alien-invalid-user)
      * [Error - Not authorized](#no_entry_sign-not-authorized-to-create) 
      * [Error - Invalid record](#boom-record-is-invalid)
    * [**Update** - BaseUpdateService](#white_check_mark-crud-update)  
      * [I18n Setup](#earth_asia-i18n-setup)
      * [Error - Invalid User](#update-resource-user-invalid)  
      * [Error - Resource don't belongs to user](#update-resource-dont-belongs-to-user)  
      * [Error - Resource dont exists](#update-resource-dont-exists)  
    * [**Delete** - BaseDeleteService](#white_check_mark-crud-delete)
        * [I18n Setup](#earth_africa-i18n-setup)  
        * [Error - Invalid User](#delete-resource-user-invalid)  
        * [Error - Resource don't belongs to user](#delete-resource-dont-belongs-to-user)  
        * [Error - Resource dont exists](#delete-resource-dont-exists)  
   * [I18n Setup](#us-fr-jp-i18n-support-uk-es-de)
   * [Callbacks](#callbacks)
      * [Using custom callbacks](#creating-custom-callbacks)
   * [Configuration](#construction-configuration-construction)
   * [Web Frameworks integration](#web-frameworks-integrations)
      * [Ruby on Rails](#frameworks-rails)
      * [Grape/Sinatra/Rack](#frameworks-rack) 
   * [CLI Generators](#cli-generators)
   * [Roadmap](#roadmap)
   * [Development](#computer-development)
   * [Contributing](#thumbsup-contributing)
   * [License - MIT](#memo-license)

---

## Conventions

Below, some very importants things about conventions for this cute :gem: :)

### :white_check_mark: Single responsibility <a name="conventions-single-responsibility"></a>

Each service class is responsible for perform exactly [one single task](https://en.wikipedia.org/wiki/Single_responsibility_principle), say goodbye for code (most important: logic) duplication in your code.
Beside this, one of the aim of NiftyServices is to provide a **very standardized** code architecture, allowing developers to quickly develop and implement new features keeping the application codebase organized and stable.

### :hammer: Common and single-run execution method

Each service object must respond to `#execute` instance method, which is allowed to be **called just one time** per instance.
`#execute` method is responsible to perform code validation(parameter validation, access level control), execution(send mail, register users) and fire callbacks so you can execute hooks actions **after/before success or execution fail**.

### :package: Rich Service Objects

When dealing with services objects, you will get a very rich objects to work with, forgot about getting only `true or false` return values, one of the main purpose of objects it's to keep your code domain logic accessible and reusable, so your application can really take the best approach when responding to actions.

### :lock: Security - Access Control Level

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

* &#9745; There's a very simple DSL for marking result as success/fail (eg: `unprocessable_entity_error!` or `success_response`).  

* &#9745; Simple DSL for actions callbacks inside current execution context. (eg: `after_success` or `before_error`)   
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

This is really great and nifty, no? But we already started, there's some really cool stuff when dealing with **Restful** API's actions, before entering this subject let's see how to handle error and success response.

---

## Success & Error Responses

### :white_check_mark: Handling Success :zap:

To mark a service running as successfully, you must call one of this methods (preferencially inside of `execute_action` block):

* `success_response # [200, :ok]`
* `success_created_response [201, :created]`

The first value in comments above is the value which will be defined to `service.response_status_code` and the last is the value set to `service.response_status`.

---


### :red_circle: Handling Error :boom: 

By default, all services comes with following error methods:
(**Hint**: See all available error methods [`here`](lib/nifty_services/configuration.rb#L10-L16))

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

```ruby
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

But you can always add new convenience errors methods via API, this way you will have more expressivity and sintax sugar:

```ruby
## API
NiftyServices.add_response_error_method(status, status_code)

## eg: 

NiftyServices.add_response_error_method(:conflict, 409)

## now you have the methods:

## conflict_error(:conflict_error)
## conflit_error!(:conflict_error)
``` 

---

## CRUD Services

So, until now we saw how to use `NiftyServices::BaseService` to create generic services to couple specific domain logic for actions,  this is very usefull, but things get a lot better when you're working with **CRUD** actions for your api.

Follow an example of **Create, Update and Delete** CRUD services for `Post` resource:

## :white_check_mark: CRUD: Create

```ruby
class PostCreateService < NiftyServices::BaseCreateService
 
 # record_type must be a object respond to :build and :save methods
 # is possible to access this record outside of service using
 # `service.record` or `service.post`
 # if you want to create a custom alias name, use:
 # record_type Post, alias_name: :user_post
 # This way, you can access the record using
 # `service.user_post`
 
 record_type Post
 
 WHITELIST_ATTRIBUTES = [:title, :content]
 
 def record_params_whitelist
  WHITELIST_ATTRIBUTES
 end
 
 def build_record
   # record_allowed_params auto magically use record_params_whitelist to remove unsafe attributes
   @user.posts.build(record_allowed_params)
 end
 
 # this key is used for I18n translations
 def record_error_key
   :posts
 end
 
 def user_can_create_record?
   # (here you can do any kind of validation, eg:)
   # check if user is trying to recreate a recent resource
   # this will return false if user has already created a post with
   # this title in the last 30 seconds (usefull to ban bots)
   @user.posts.exists(title: record_allowed_params[:title], created_at: "NOW() - interval(30 seconds)")
 end
end

service = PostCreateService.new(User.first, title: 'Teste', content: 'Post example content')

service.execute

service.success? # true
service.response_status_code # 200
service.response_status # :created
```

#### :earth_americas: I18n setup 

You must have the following keys setup up in your locales files:

```yml
 nifty_services:
   users:
     not_found: "Invalid or not found user"
     ip_temporarily_blocked: "This IP is temporarily blocked from creating records" 
   # note: posts is the key return in `record_error_key` service method
   posts:
      user_cant_create: "User cant create this record"
```

#### :alien: Invalid user <a name="create-resource-user-invalid"></a>

If you try to create a post for a invalid user, such as:

```ruby
# PostCreateService.new(user, options)
service = PostCreateService.new(nil, options)
service.execute

service.success? # false
service.response_status # :not_found
service.response_status_code # 404
service.errors # ["Invalid or not found user"]
```

#### :no_entry_sign: Not authorized to create

Or if user is trying to create a duplicate resource:

```ruby
# PostCreateService.new(user, options)
service = PostCreateService.new(User.first, options)
service.execute

service.success? # false
service.errors # ["User cant create this record"]
service.response_status # :forbidden_error
service.response_status_code # 400
```

#### :boom: Record is invalid

Eg: if any validation in Post model won't pass:

```ruby
# PostCreateService.new(user, options)
# Post model as the validation:
# validates_presence_of :title, :content
service = PostCreateService.new(User.first, title: nil, content: nil)
service.execute

service.success? # false

service.errors # => [{ title: 'is empty', content: 'is empty' }]

service.response_status # :unprocessable_entity
service.response_status_code # 422
```
---

## :white_check_mark: CRUD: Update

```ruby
class PostUpdateService < NiftyServices::BaseUpdateService
  
  # service.post or service.record
  record_type Post
  
  WHITELIST_ATTRIBUTES = [:title, :content] 
  
  def record_allowed_params
   WHITELIST_ATTRIBUTES
  end
  
  # by default, internally @record must respond to
  # user_can_update(user)
  # so you can do specific validations per resource
  def user_can_update_record?
   # only system admins and owner can update this record
   @user.admin? || @user.id == @record.id
  end
  
  def record_error_key
    :posts
  end
end

# :user_id will be ignored since it's not in whitelisted attributes
# this can safe yourself from parameter inject attacks, by default
update_service = PostUpdateService.new(Post.first, User.first, title: 'Changing title', content: 'Updating content', user_id: 2)

update_service.execute

update_service.success? # true
update_service.response_status # :ok
update_service.response_status_code # 200

update_service.changed_attributes # [:title, :content]
update_service.changed? # true
```

#### :earth_asia: I18n setup

Your locale file must have the following keys:

```yml
 posts:
   not_found: "Invalid or not found post"
   user_cant_update: "User can't update this record"
 users:
   not_found: "Invalid or not found user"
```

#### :alien: User is invalid <a name="update-resource-user-invalid"></a>

Response when owner user is not valid:

```ruby
# PostUpdateService.new(post, user, params)
update_service = PostUpdateService.new(Post.first, nil, title: 'Changing title', content: 'Updating content')

update_service.execute

update_service.success? # false
update_service.response_status # :not_found_error
update_service.response_status_code # 404

update_service.errors # ["Invalid or not found user"]
```

#### :closed_lock_with_key: Resource (Post) don't belongs to user <a name="update-resource-dont-belongs-to-user"></a>

Responses when trying to update to update a resource who don't belongs to owner:

```ruby
# PostUpdateService.new(post, user, params)
update_service = PostUpdateService.new(Post.first, User.last, title: 'Changing title', content: 'Updating content')

update_service.execute

update_service.success? # false
update_service.response_status # :forbidden
update_service.response_status_code # 400

update_service.changed_attributes # []
update_service.changed? # false
update_service.errors # ["User can't update this record"]
```

#### :santa: Resource don't exists <a name="update-resource-dont-exists"></a>

Response when post don't exists:

```ruby
# PostUpdateService.new(post, user, params)
update_service = PostUpdateService.new(nil, User.last, title: 'Changing title', content: 'Updating content')

update_service.execute

update_service.success? # false
update_service.response_status # :not_found_error
update_service.response_status_code # 404

update_service.errors # ["Invalid or not found post"]
```

---

## :white_check_mark: CRUD: Delete

```ruby
class PostDeleteService < NiftyServices::BaseDeleteService
  # record_type object must respond to :destroy or :delete method
  record_type Post
  
  def record_error_key
    :posts
  end
  
  # below the code used internally, you can override to
  # create custom delete, but remembers that this method
  # must return a boolean value
  def destroy_record
    @record.try(:destroy) || @record.try(:delete)
  end
  
  # by default, internally @record must respond to
  # @record.user_can_delete?(user)
  # so you can do specific validations per resource
  def user_can_delete_record?
   # only system admins and owner can delete this record
   @user.admin? || @user.id == @record.id
  end
end
```

#### :earth_africa: I18n setup

Your locale file must have the following keys:

```yml
 posts:
   not_found: "Invalid or not found post"
   user_cant_delete: "User can't delete this record"
 users:
   not_found: "Invalid or not found user"
```

#### :alien: User is invalid <a name="delete-resource-user-invalid"></a>

Response when owner user is not valid:

```ruby
# PostDeleteService.new(post, user, params)
delete_service = PostDeleteService.new(Post.first, nil)

delete_service.execute

delete_service.success? # false
delete_service.response_status # :not_found_error
delete_service.response_status_code # 404

delete_service.errors # ["Invalid or not found user"]
```

#### :closed_lock_with_key: Resource don't belongs to user <a name="delete-resource-dont-belongs-to-user"></a>

Responses when trying to delete a resource who don't belongs to owner:

```ruby
# PostDeleteService.new(post, user, params)
delete_service = PostDeleteService.new(Post.first, User.last)
delete_service.execute

delete_service.success? # false
delete_service.response_status # :forbidden
delete_service.response_status_code # 400
delete_service.errors # ["User can't delete this record"]
```

#### :santa: Resource(Post) don't exists <a name="delete-resource-dont-exists"></a>

Response when post don't exists:

```ruby
# PostDeleteService.new(post, user, params)
delete_service = PostDeleteService.new(nil, User.last)

delete_service.execute

delete_service.success? # false
delete_service.response_status # :not_found_error
delete_service.response_status_code # 404

delete_service.errors # ["Invalid or not found post"]
```


---

## :us: :fr: :jp: I18n Support :uk: :es: :de:

As you see in the above examples, with `NiftyServices` you can respond in multiples languages for the same service error messages, by default your locales config file must be configured as:

```yml
 # attention: dont use `resource_type`
 # use the key setup up in `record_error_key` methods
 resource_type:
   not_found: "Invalid or not found post"
      user_cant_create: "User can't delete this record"
      user_cant_read: "User can't access this record"
      user_cant_update: "User can't delete this record"
      user_cant_delete: "User can't delete this record"
 users:
   not_found: "Invalid or not found user"
```

You can configure the default I18n namespace using configuration:

```ruby
NiftyServies.configure do |config|
  config.i18n_namespace = :my_app
end
```

Example config for `Post` and `Comment` resources using `my_app` locale namespace:  

```yml
# default is nifty_services
my_app:
 errors:
  default_crud: &default_crud
    user_cant_create: "User can't delete this record"
    user_cant_read: "User can't access this record"
    user_cant_update: "User can't delete this record"
    user_cant_delete: "User can't delete this record"
  users:
   not_found: "Invalid or not found user"
  posts:
    <<: *default_crud
    not_found: "Invalid or not found post"
  comments:
    <<: *default_crud
    not_found: "Invalid or not found comment"
```

---

## Callbacks

Here the most common callbacks list you can use to hook actions in run-time:
(**Hint**: See all existent callbacks definitions in [`extensions/callbacks_interface.rb`](lib/nifty_services/extensions/callbacks_interface.rb#L8-L24) file)

```
  - before_initialize
  - after_initialize
  - before_execute
  - after_execute
  - before_error
  - after_error
  - before_success
  - after_success
```

### Creating custom Callbacks

Well, probably you will need to add custom callbacks to your services, in my case I need to save in database an object which tracks information about the environment used to create **ALL RECORDS** in my application, I was able to do it with just a few lines of code, see for yourself:

```ruby
# Some monkey patch :)

NiftyServices::BaseCreateService.class_eval do
  ORIGIN_WHITELIST_ATTRIBUTES = [:provider, :locale, :user_agent, :ip]

  def origin_params(params = {})
    filter_hash(params.fetch(:origin, {}).to_h, ORIGIN_WHITELIST_ATTRIBUTES)
  end

  def create_origin(originable, params = {})
    return unless originable.respond_to?(:create_origin)
    return unless create_origin?
    
    originable.create_origin(origin_params(params))
  end
  
  # for records which we don't need to create origins, just
  # overwrite this method inside service class turning it off with:
  # return false
  def create_origin?
    Application::Config.create_origin_for_records
  end
end

# This register a callback for ALL services who inherit from `NiftyServices::BaseCreateService`
# In other words: Every and all records created in my application will be tracked
# I can believe that is easy like this, I need a beer right now!
NiftyServices::BaseCreateService.register_callback(:after_success, :create_origin_for_record) do
  create_origin(@record, @options)
end

```

Now, every record created in my application will have an associated `origin` object, really simple and cool!

---

## :construction: Configuration :construction:

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

### Rails <a name="frameworks-rails"></a>

You need a very minimal setup to integrate with your existing or new Rails application. I prefer to put my services files inside the `lib/services` folder, cause this allow better namespacing configuration over `app/services`, but this is up to you to decide.

First thing to do is add `lib/` folder in `autoload` path, place the following in your `config/application.rb`

```ruby
# config/application.rb
config.paths.add(File.join(Rails.root, 'lib'), glob: File.join('**', '*.rb'))

config.autoload_paths << Rails.root.join('lib')
```

Second, create `lib/services` directory:

`$ mkdir -p lib/services/v1/users`

Next, configure:  

```ruby
NiftyServices.configure do |config|
 config.user_class = User
end
```
**Note**:  See [Configurations](#construction-configuration-construction) section to see all available configs

Create your first service:

```
$ touch lib/services/v1/users/create_service.rb
```

Use in your controller:

```ruby
class UsersController < BaseController
  def create
    service = Services::V1::Users::CreateService.new(params).execute

    default_response = { status: service.response_status, status_code: service.response_status_code }
    
    if service.success?
      response = { user: service.user, subscription: service.subscription }
    else
      response = { error: true, errors: service.errors }
    end

    render json: default_response.merge(response), status: service.response_status
  end
end
```

This can be even better if you move response code to a helper:

```ruby
# helpers/users_helper.rb
module UsersHelper

  def response_for_user_create_service(service)
    success_response = { user: service.user, subscription: service.subscription }
    generic_response_for_service(service, success_response)
  end

  # THIS IS GREAT, you can use this method to standardize ALL of your
  # endpoints responses, THIS IS SO FUCKING COOL!
  def generic_response_for_service(service, success_response)
    default_response = {
      status: service.response_status,
      status_code: service.response_status_code,
      success: service.success?
    }

    if service.success?
      response = success_response
    else
      response = {
        error: true,
        errors: service.errors
      }
    end

    default_response.merge(response)
  end
end
```

Changing controller again: (looks so readable now <3)

```ruby
# controllers/users_controller.rb
class UsersController < BaseController
  def create
    service = Services::V1::Users::CreateService.new(params).execute

    render json: response_for_user_create_service(service), status: service.response_status
  end
end
```

Well done sir! Did you read the comments in `generic_response_for_service`? Read it and think a little about this and  prepare yourself for having orgasms when you realize how fuck awesome this will be for your API's. Need mode? Checkout [Sample Standartized API with NiftyServices Repository](http://github.com/fidelisrafael/nifty_services-api_sample)

---

### Grape/Sinatra/Padrino/Hanami/Rack <a name="frameworks-rack"></a>

Well, the integration here don't variate too much from Rails, just follow the steps:

**1 -** Decide where you'll put your services  
**2 -** Code that dam amazing services!  
**3 -** Instantiate the service in your framework entry point  
**4 -** Create helpers to handle service response  
**5 -** Be happy and go party!  

Need examples? Check out one of the following repositories:  

NiftyServices - Rails Sample    
NiftyServices - Grape Sample   
NiftyServices - Sinatra Sample   

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

## :question: CLI Generators <a name="cli-generators"></a>

Currently NiftyServices don't have CLI(command line interface) generators, but is in the roadmap, so keep your eyes here!

---

## :calendar: Roadmap <a name="roadmap"></a>

- :white_medium_small_square: Remove ActiveSupport dependency
- :white_medium_small_square: Create CLI Generators
- :white_medium_small_square: Document `BaseActionService`
- :white_medium_small_square: Write Sample Applications
- :white_medium_small_square: Write better tests for all `Crud Services`
- :white_medium_small_square: Write better tests for `BaseActionServices`
- :white_medium_small_square: Write tests for Configuration
- :white_medium_small_square: Write tests for Callbacks
 
---

## :computer: Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem(:gem:) onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

---

## :thumbsup: Contributing

Bug reports and pull requests are welcome on GitHub at http://github.com/fidelisrafael/nifty_services. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

---

## :memo: License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
