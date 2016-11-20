# NiftyServices documentation

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
**Note**:  See [Configurations](./configuration.md) section to see all available configs

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
  include GenericHelpers

  def response_for_user_create_service(service)
    success_response = { user: service.user, subscription: service.subscription }
    generic_response_for_service(service, success_response)
  end

end
```

```ruby
# helpers/generic_helper.rb
module GenericHelper

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

---

## Integration Examples

Need examples of integrations fully working? Check out one of the following repositories:

[NiftyServices - Sinatra Sample](https://github.com/fidelisrafael/nifty_services-sinatra_example)
NiftyServices - Grape Sample
NiftyServices - Rails Sample

---

### Next

See [Basic Services class Markups](./services_markup.md)
