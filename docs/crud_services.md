# NiftyServices documentation

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

 def record_attributes_whitelist
  WHITELIST_ATTRIBUTES
 end

 # use custom scope to create the record
 # scope returned below must respond_to :build method
 def build_record_scope
   @user.posts
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
   @user.posts.exists(title: record_allowed_attributes[:title], created_at: "NOW() - interval(30 seconds)")
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

  def record_allowed_attributes
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
    @record.destroy
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

### Next

See [I18n Configuration](./i18n.md)
