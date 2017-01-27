# NiftyServices documentation

---

## CRUD Services

So, until now we saw how to use `NiftyServices::BaseService` to create generic services to couple specific domain logic for actions,  this is very usefull, but things get a lot better when you're working with **CRUD** actions for your api.

Follow an example of **Create, Update and Delete** CRUD services for `Post` resource:

## :white_check_mark: CRUD: Create

By default, NiftyServices expect that record responds to `new` class method. (eg: `Post.new`).

NiftyServices will expect that record respond to `#save` instance method when trying to save the record after creating it, you can override this behavior using the method `save_record` or using global configuration:

```ruby
NiftyServices.config do |config|
  # The default value is `save`, this will call:`record.save`
  # Eg: If you want to use `#persist`(`record.persist`), use:
  config.save_record_method = :persist

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call the method sending the record as argument.
  config.save_record_method = ->(record) {
    record.save_in_database!
  }
end
```


```ruby
class PostCreateService < NiftyServices::BaseCreateService

  attr_reader :user

  # You can freely override initialize method to receive more arguments
  def initialize(user, options = {})
    @user = user
    super(options)
  end

  # record_type must be a object respond to :build and :save methods
  # is possible to access this record outside of service using
  # `service.record` or `service.post`
  # if you want to create a custom alias name, use:
  # record_type Post, alias_name: :user_post
  # This way, you can access the record using
  # `service.user_post`

  record_type Post

  WHITELIST_ATTRIBUTES = [:title, :content]

  whitelist_attributes WHITELIST_ATTRIBUTES


  # use custom scope to create the record
  # scope returned below must respond_to :build method
  def build_record_scope
    @user.posts
  end

  # this key is used for I18n translations, you don't need to override or implement
  # NiftyService will try to inflect this using `record_type.to_s.underscore + 's'`
  # So, if your record type is `Post`, `record_error_key` will be `posts`
  def record_error_key
    :posts
  end

  # This method is strict required by NiftyServices, each service must implement
  def can_create_record?
    # Checking user before trying to create a post for this same user
    unless valid_user?
      return not_found_error!('users.not_found')
    end

    return !duplicated?
  end

  def duplicated?
    # (here you can do any kind of validation, eg:)
    # check if user is trying to recreate a recent resource
    # this will return false if user has already created a post with
    # this title in the last 30 seconds (usefull to ban bots)
    @user.posts.exists(title: record_allowed_attributes[:title], created_at: "NOW() - interval(30 seconds)")
  end

  # This is a custom method of this class, not NiftyService stuff
  def valid_user?
    # `valid_object?` signature: `valid_object?(object, expected_class)`
    valid_object?(@user, User)
  end
end

service = PostCreateService.new(User.first, title: 'Teste', content: 'Post example content')

service.execute

service.success? # true
service.response_status_code # 201
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
      cant_create: "Can't create this record"
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

By default, NiftyServices expect that record responds to `update` class method. (eg: `Post.update(id, data)`)

You can override this behavior using `update_record` method in your service class, or using global configuration:

```ruby
NiftyServices.config do |config|
  # Set the method called when updating a record using BaseUpdateService
  # Eg: If you want to use `sync`(`record.sync(attributes)`), use:
  config.update_record_method = :sync

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call the method sending the record and attributes.
  config.update_record_method = ->(record, attributes) {
    record.update_attributes(attributes)
  }
end
```

For validation, NiftyServices expect that record respond to `#valid?` and `#errors` instance methods.

You can override this behavior using `success_updated?` and `update_errors` methods.


```ruby
class PostUpdateService < NiftyServices::BaseUpdateService

  attr_reader :user

  # service.post or service.record
  record_type Post

  WHITELIST_ATTRIBUTES = [:title, :content]

  whitelist_attributes WHITELIST_ATTRIBUTES

  # You can freely override initialize method to receive more arguments
  def initialize(record, user, options = {})
    @user = user
    super(record, options)
  end

  # This method is strict required by NiftyServices, each service must implement
  def can_update_record?
    unless valid_user?
     return not_found_error!('users.not_found')
    end

    return user_has_permission?
  end

  def user_has_permission?
    # only system admins and owner can update this record
    # or you can transfer the logic below to something like:
    # @record.user_can_update_record?(@user)
    @user.admin? || @user.id == @record.id
  end

  # this key is used for I18n translations, you don't need to override or implement
  def record_error_key
    :posts
  end

  # This is a custom method of this class, not NiftyService stuff
  def valid_user?
    valid_object?(@user, User)
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
   cant_update: "Can't update this record"
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


By default, NiftyServices expect that record responds to `delete` instance method. (eg: `post.delete`)

You can override this behavior using `delete_record` method in your Service class, or using global configuration:

```ruby
NiftyServices.config do |config|
  # The default value is `delete`, this will call:`record.delete`
   # Eg: If you want to use `#destroy`(`record.destroy`), use:
  config.delete_record_method = :destroy

  # But you can pass any object that responds to `#call` method, like a Proc:
  # This way, NiftyServices will call the method sending the record
  config.delete_record_method = ->(record) {
    record.remove
  }
end
```


```ruby
class PostDeleteService < NiftyServices::BaseDeleteService

  attr_reader :user

  # record_type object must respond to :delete method
  # But you can override `delete_method` method to do whatever you want
  record_type Post

  # You can freely override initialize method to receive more arguments
  def initialize(record, user, options = {})
    @user = user
    super(record, options)
  end

  # this key is used for I18n translations, you don't need to override or implement
  def record_error_key
    :posts
  end

  # below the code used internally, you can override to
  # create custom delete, but remembers that this method
  # must return a boolean value
  def delete_record
    @record.delete
  end

  # This method is strict required by NiftyServices, each service must implement
  def can_delete_record?
    # Checking user before trying to create a post for this same user
    unless valid_user?
      return not_found_error!('users.not_found')
    end

    return user_has_permission?
  end

  def user_has_permission?
   # only system admins and owner can delete this record
   # or you can transfer the logic below something like:
   # @record.user_can_delete_record?(@user)
   @user.admin? || @user.id == @record.id
  end

  # This is a custom method of this class, not NiftyService stuff
  def valid_user?
    valid_object?(@user, User)
  end
end
```

#### :earth_africa: I18n setup

Your locale file must have the following keys:

```yml
 posts:
   not_found: "Invalid or not found post"
   cant_delete: "Can't delete this record"
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

#### Tip

You can DRY the examples above using `concerns`, if you take a look you will see
that in `PostUpdateService` and `PostDeleteService` same validation
methods are repeated, so lets improve this, first thing is create a Ruby plain module:

```ruby
module PostCrudExtensions
  # You can freely override initialize method to receive more arguments
  def initialize(record, user, options = {})
    @user = user
    super(record, options)
  end

  def record_allowed_attributes
    WHITELIST_ATTRIBUTES
  end

  def self.whitelist_attributes
    WHITELIST_ATTRIBUTES
  end

  def user_has_permission?
    # only system admins and owner can update this record
    # or you can transfer the logic below to something like:
    # @record.user_can_update_record?(@user)
    @user.admin? || @user.id == @record.id
  end

  # this key is used for I18n translations, you don't need to override or implement
  def record_error_key
    :posts
  end

  def valid_user?
    valid_object?(@user, User)
  end
end
```

The second step, is call class method `concern` in Service class, lets use `PostDeleteService`

```ruby
class PostDeleteService < NiftyServices::BaseDeleteService

  # Include shared CRUD methods to Post's CRUD Services
  concern PostCrudExtensions

  # record_type object must respond to :delete method
  # But you can override `delete_method` method to do whatever you want

  # below the code used internally, you can override to
  # create custom delete, but remembers that this method
  # must return a boolean value
  def delete_record
    @record.delete
  end

  # This method is strict required by NiftyServices, each service must implement
  def can_delete_record?
    # Checking user before trying to create a post for this same user
    unless valid_user?
      return not_found_error!('users.not_found')
    end

    return user_has_permission?
  end
end
```

The code is much more readable and DRY now.

Now, you can share `PostCrudExtensions` will all others Post related CRUD services.

### Next

See [I18n Configuration](./i18n.md)
