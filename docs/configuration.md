# NiftyServices documentation

---

## :construction: Configuration :construction:

There are only a few things you must want and have to configure for your services work properly, below you can see all needed configuration:

```ruby
NiftyServices.config do |config|
  # [optional]
  # global logger for all services
  # [Default: Logger.new('/dev/null')]
  config.logger = Logger.new('log/services_logger.log')

  # [Optional - Default: `'nifty_services'`]
  # Set a custom I18n lookup namespace for error messages
  config.i18n_namespace = 'my_app'

  # [Optional - Default: `save`]
  # Set the method called when saving a record using `BaseCreateService`
  # The default value is `save`, this will call:`record.save`
  # Eg: If you want to use `#persist`(`record.persist`), use:
  config.save_record_method = :persist

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call the method sending the record as argument.
  config.save_record_method = ->(record) {
    record.save_in_database!
  }

  # [Optional - Default: `delete`]
  # Set the method called when deleting a record using BaseDeleteService
  # The default value is `delete`, this will call:`record.delete`
  # Eg: If you want to use `#destroy`(`record.destroy`), use:
  config.delete_record_method = :destroy

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call the method sending the record as argument.
  config.delete_record_method = ->(record) {
    record.remove
  }

  # [Optional - Default: `update`]
  # Set the method called when updating a record using BaseUpdateService
  # The default value is `update`, this will call:`record.update(attributes)`
  # Eg: If you want to use `sync`(`record.sync(attributes)`), use:
  config.update_record_method = :sync

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call this block sending the record and attributes as arguments.
  config.update_record_method = ->(record, attributes) {
    record.update_attributes(attributes)
  }
end
```

---

### Next

See [Web Frameworks Integration](./webframeworks_integration.md)
