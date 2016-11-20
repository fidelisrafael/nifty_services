# NiftyServices documentation

---

## :pray: Basic Service Markups :raised_hands:

Here, for your convenience and sanity all basic service structures for reference when you start a brand new Service.
Most of time, the best way is to copy all content from each service described below and change according to your needs.

### BaseCreateService Basic Markup

```ruby
class SomeCreateService < NiftyServices::BaseCreateService

 # [Required]
 # remember that inside the Service you always can use
 # @record variable to access current record
 # and from outside (service instance):
 # service.record or service.record_type
 # eg:
 # record_type BlogPost
 # service.record # BlogPost.new(...)
 # service.blog_post # BlogPost.new(...)
 # service.record == service.blog_post # true
 # alias_name can be used to create a custom alias name
 # eg:
 # record_type BlogPost, alias_name: :post
 # service.record # BlogPost.new(...)
 # service.post # BlogPost.new(...)
 # service.record == service.post # true

 record_type RecordType, alias_name: :my_custom_alias_name

 private
 # [Required]
 # Always validate if @user can create the current record_type
 # If this method is not implemented a NotImplementedError exception will be raised
 def user_can_create_record?
  return forbidden_error!('errors.some_error') if (some_validation)

  return bad_request_error!('errors.some_other_error') if (another_validation)

  # remember to return true after all validations
  # if you don't return true Service will not be able to create the record
  return true
 end

 # [Optional]
 # method called when save_error method call raises an exception
 # this ocurr for example with ActiveRecord objects
 # default: unprocessable_entity_error!(error)
 def on_save_record_error(error)
   logger.error(error)
   if error.is_a?(ActiveRecord::RecordNotUnique)
     return unprocessable_entity_error!(%s(posts.duplicate_record))
   end
 end

 # [Optional]
 # determine wheter user will be validate as valid object before
 # record creation
 # (default: true)
 def validate_user?
  return true
 end

 # [Optional]
 # custom scope for record, eg: @user.posts
 # default is nil
 def build_record_scope
 end
end
```

### BaseUpdateService Basic Markup

```ruby
class SomeUpdateService < NiftyServices::BaseUpdateService

  # [Required]
  record_type RecordType, alias_name: :custom_alias_name

  WHITELIST_ATTRIBUTES = [
    :safe_attribute_1,
    :safe_attribute_2,
  ]

  private
  # [Required]
  # When a new instance of Service is created, the @options variables receive some
  # values, eg: { user: { email: "...", name: "...."} }
  # use record_attributes_hash to tell the Service from where to pull theses values
  # eg: @options.fetch(:user, {})
  # If this method is not implemented a NotImplementedError exception will be raised
  def record_attributes_hash
    @options.fetch(options_key, {})
  end

  # [Required]
  # whitelisted attributes (must be an Array) which can be updated by this Service
  # If this method is not implemented a NotImplementedError exception will be raised
  def record_attributes_whitelist
    WHITELIST_ATTRIBUTES
  end

  # [required]
  # This is a VERY IMPORTANT point of attention
  # always verify if @user has permissions to update the current @record object
  # Hint: if @record respond_to `user_can_update?(user)` you can remove this
  # method and do the validation inside `user_can_update(user)` method in @record
  # If this method is not implemented a NotImplementedError exception will be raised
  def user_can_update_record?
    @record.user_id == @user.id
  end


  # [Optional]
  # This is the default implementation of update record, you may overwrite it
  # to to custom updates (MOST OF TIME YOU DONT NEED TO DO THIS)
  # only change this if you know what you are really doing
  def update_record
    @record.class.send(:update, @record.id, record_allowed_attributes)
  end


  # [optional]
  # Any callback is optional, this is just a example
  def after_success
    if changed?
      logger.info 'Successfully update record ID %s' % @record.id
      logger.info 'Changed attributes are %s' % changed_attributes
    end
  end
end
```

---

### BaseDeleteService Basic Markup

```ruby
class SomeDeleteService < NiftyServices::BaseDeleteService

  # [Required]
  record_type RecordType, alias_name: :custom_alias_name

  private

  # [Required]
  # This is a VERY IMPORTANT point of attention
  # always verify if @user has permissions to delete the current @record object
  # Hint: if @record respond_to `user_can_delete?(user)` you can remove this
  # method and do the validation inside `user_can_delete(user)` method in @record
  # If this method is not implemented a NotImplementedError exception will be raised

  def user_can_delete_record?
    @record.user_id == @user.id
  end

  # [optional]
   # Any callback is optional, this is just a example
  def after_success
    logger.info('Successfully Deleted resource ID %s' % @record.id)
  end

  # [Optional]
  # This is the default implementation of delete record, you may overwrite it
  # to do custom delete (MOST OF TIME YOU DONT NEED TO DO THIS)
  # only change this if you know what you are really doing
  def destroy_record
    @record.destroy
  end

end

```

### BaseActionService Basic Markup

```ruby
class SomeCustomActionService < NiftyServices::BaseActionService

  # [required]
  # this is the action identifier used internally
  # and to generate error messages
  # see: invalid_action_error_key method
  action_name :custom_action_name

  private
  # [Required]
  # Always validate if Service can execute the action
  # This method MUST return a boolean value indicating if Service can or not
  # run the method `execute_service_action`
  # If this method is not implemented a NotImplementedError exception will be raised
  def user_can_execute_action?
    # do some specific validation here, you can return errors such:
    # return not_found_error!(%(users.invalid_user)) # returns false and avoid execution
    return true
  end

  # [Required]
  # The core function of BaseActionServices
  # This method is called when all validations passes, so here you can put
  # all logic for Service (eg: send mails, clear logs, any kind of action you want)
  # If this method is not implemented a NotImplementedError exception will be raised
  def execute_service_action
    # (do some complex stuff)
  end

  # You dont need to overwrite this method, just `record_error_key`
  # But it's important you know how final message key will be created
  # using the pattern below
  def invalid_action_error_key
    "#{record_error_key}.cant_execute_#{action_name}"
  end

  # [Required]
  # Key used to created the error messages for this Service
  # If this method is not implemented a NotImplementedError exception will be raised
  def record_error_key
    :users
  end
end
```

---

### Next

See [CLI Generators](./cli.md)
