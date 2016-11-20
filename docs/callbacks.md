# NiftyServices documentation

---

## Callbacks

Here the most common callbacks list you can use to hook actions in run-time:
(**Hint**: See all existent callbacks definitions in [`extensions/callbacks.rb`](lib/nifty_services/extensions/callbacks.rb#L7-L22) file)

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

### Next

See [Configuration](./configuration.md)
