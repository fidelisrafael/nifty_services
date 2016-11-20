# NiftyServices documentation

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

### Next

See [Web Frameworks Integration](./webframeworks_integration.md)
