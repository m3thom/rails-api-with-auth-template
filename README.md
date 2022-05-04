This Rails 6 API only. Created with devise, devise-jwt and based on  
https://medium.com/@nandhae/2019-how-i-set-up-authentication-with-jwt-in-just-a-few-lines-of-code-with-rails-5-api-devise-9db7d3cee2c0

**At your custom**

- Custom mailer. https://www.truemark.dev/blog/reset-password-in-react-and-rails
- Refresh user token. https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-716185500

***

# To Run the project

```bash
rails db:setup

rails db:migrate

rails s
```

***

# Step to create from scratch.

**STEP 1: Configure Rack Middleware**

`/cors.rb`

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource(
        '*',
        headers: :any,
        expose: ["Authorization"],
        methods: [:get, :patch, :put, :delete, :post, :options, :show]
    )
  end
end
```

**STEP 2: Add the needed Gems**

```ruby
gem 'devise', '~> 4.8.0'

gem 'devise-jwt', '~> 0.9.0'

gem 'dotenv-rails'
```

Then

```bash
bundle install
```

**STEP 3: Install and configure devise**

```bash
rails generate devise:install
```

At `/config/environments/development.rb`

```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

**STEP 4: Create User model**

```bash
rails generate devise User

rails db:create

rails db:migrate
```

**STEP 5: Create devise controllers and routes**

**For controllers**

Look at `app/controllers/users/registrations_controller.rb` and `app/controllers/users/sessions_controller.rb`
for more information.

**For routes**

At `/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }
end
```

**For STEP 6: Configure devise-jwt**

Create `.env.development` at your project root directory

```bash
bundle exec rake secret
```

Then add it to `.env.development`

```bash
DEVISE_SECRET_KEY=SECRET_FROM_BUNDLE_EXEC_RAKE_SECRET
```

At `/devise.rb`

```ruby
config.jwt do |jwt|
  jwt.secret = ENV['DEVISE_SECRET_KEY']
  jwt.dispatch_requests = [
      ['POST', %r{^/users$}], # Default registration path from devise.
      ['POST', %r{^/users/sign_in$}], # Default sign_in path from devise.
  ]
  jwt.revocation_requests = [
      ['DELETE', %r{^/sign_out}] # Default sign_out path from devise.
  ]
  jwt.expiration_time = 5.minutes.to_i 
end
```

**STEP 7: Set up a revocation strategy**

For more info https://github.com/waiting-for-dev/devise-jwt

`Option 1 :`

```bash
rails g model jwt_denylist jti:string:index exp:datetime
```

At `/app/models/jwt_denylist.rb` add

```ruby
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end
```

At `app/models/user.rb`

```ruby
class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable, 
         jwt_revocation_strategy: JwtDenylist
end
```

`Option 2 :`

```bash
rails g migration create_allowlisted_jwts
```

At generated `_create_allowlisted_jwts.rb` migration file

```ruby
def change
  create_table :allowlisted_jwts do |t|
    t.string :jti, null: false
    t.string :aud
    # If you want to leverage the `aud` claim, add to it a `NOT NULL` constraint:
    # t.string :aud, null: false
    t.datetime :exp, null: false
    t.references :users, foreign_key: { on_delete: :cascade }, null: false
  end

  add_index :allowlisted_jwts, :jti, unique: true
end
```

Create `allowlisted_jwt.rb` model

```ruby
class AllowlistedJwt < ApplicationRecord
end
```

At `user.rb` model

```ruby
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable,
         :jwt_authenticatable, 
         jwt_revocation_strategy: self # Use created strategy
end
```
