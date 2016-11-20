# NiftyServices documentation

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

### Next

See [Crud Services](./crud_services.md)
