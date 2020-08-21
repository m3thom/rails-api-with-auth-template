# README

This Rails 6 API only. Create with  devise, devise-jwt is base on  
https://medium.com/@nandhae/2019-how-i-set-up-authentication-with-jwt-in-just-a-few-lines-of-code-with-rails-5-api-devise-9db7d3cee2c0


# To Run the project

```
$ rails db:setup
$ rails db:migrate
$ rails s
```

***

# Note for medium column step

 * **For STEP 3: Add the needed Gems** 
 
 In **gemfile.rb** Change to use 

```
gem 'devise-jwt', '~> 0.6.0'
``` 

Instead of 
     
```
gem 'devise-jwt', '~> 0.5.8'
```

to  Fix devise-jwt compatible error

***

* **For STEP 7: Configure devise-jwt** 

After you run 

```
$ bundle exec rake secret
```

To store generated secret key in

```
jwt.secret = ENV['DEVISE_SECRET_KEY']
```

Use this command to edit credential file (editor using now is VS Code)

```
$ EDITOR="code --wait" rails credentials:edit --environment development
```

After that, Editor should automatically open credential file and the file should look like this

```
DEVISE_SECRET_KEY: secret_key_generated_bye_bundle_exec_rake_secret
``` 

This command will generate credential file for separate environment (development for above command)
so we have to change how we access secret key too


```
jwt.secret = Rails.application.credentials.config[:DEVISE_SECRET_KEY]
``` 
TIPs: You can check if DEVISE_SECRET_KEY has been setup successfully using 

```
$ rails c
```

and then run below command. The result should the same as secret_key_generated_bye_bundle_exec_rake_secret from above

```
Rails.application.credentials.config[:DEVISE_SECRET_KEY]
```

Finally your code should look like this

```
config.jwt do |jwt|
  jwt.secret = Rails.application.credentials.config[:DEVISE_SECRET_KEY]
  jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
  jwt.expiration_time = 5.minutes.to_i
end

```

***
