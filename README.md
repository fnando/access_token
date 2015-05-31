# AccessToken

[![Build Status](https://travis-ci.org/fnando/access_token.svg)](https://travis-ci.org/fnando/access_token)

A simple and easy-to-use access token generator.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'access_token'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install access_token

## Usage

```ruby
class ApplicationController < ActionController::Base
  private

  def access_token
    @access_token ||= AccessToken.new(
      request: request,
      response: response,
      secret: Rails.application.secrets.access_token_secret,
      ttl: 3600
    )
  end

  def current_user
    @current_user
  end

  def authenticate!
    @current_user = User.find_by_id(access_token.resolve)
    return render(nothing: true, status: 401) unless current_user
    access_token.update(current_user)
  end
end

class AuthController < ApplicationController
  def create
    user = User.find_by_email(params[:email].to_s)
            .try(:authenticate, params[:password].to_s)

    if user
      access_token.update(user)
      render json: user
    else
      render nothing: true, status: 401
    end
  end
end

class ProfileController < ApplicationController
  before_action :authenticate!

  def show
    render json: current_user
  end
end

Rails.application.routes.draw do
  get '/profile', to: 'profile#show'
  post '/auth', to: 'auth#create'
end
```

Now, testing authentication using [httpie](http://httpie.org).

```
$ http --form POST localhost:3000/auth email=john@example.com password=test
HTTP/1.1 200 OK
Bearer: 5A2tPbDOXrQSMH1WzsEhhPaw4rNa1sJ9j7OyAU6gr1kfaZM0xDiXUGuENKyKLC/rKuzhrDXG6FwehWhIWy3IMfhQ9n6FJwBCERlF1TavYo2lG0UM8Bz1/0vrz3DxJc/r
Cache-Control: max-age=0, private, must-revalidate
Connection: Keep-Alive
Content-Length: 196
Content-Type: application/json; charset=utf-8
Date: Mon, 01 Jun 2015 00:22:12 GMT
Etag: W/"a710bcbfd462f6c4f7fed6bd7cff32b5"
Expires: Mon, 01 Jun 2015 01:22:12 GMT
Server: WEBrick/1.3.1 (Ruby/2.2.2/2015-04-13)
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Request-Id: e4a07ab3-fa31-4058-aad5-2bcb5ce1f16e
X-Runtime: 0.102162
X-Xss-Protection: 1; mode=block

{
    "created_at": "2015-06-01T00:08:46.308Z",
    "email": "john@example.com",
    "id": 1,
    "password_digest": "$2a$10$ayl6Yj.Hu1s.sba11YuMpOwDX.fZ.zsj.lPAvyapgLf6FWZtin.FW",
    "updated_at": "2015-06-01T00:08:46.308Z"
}
```

You can use the bearer by setting the `Authorization` header.

```
$ http GET localhost:3000/profile Authorization:'Bearer 5A2tPbDOXrQSMH1WzsEhhPaw4rNa1sJ9j7OyAU6gr1kfaZM0xDiXUGuENKyKLC/rKuzhrDXG6FwehWhIWy3IMfhQ9n6FJwBCERlF1TavYo2lG0UM8Bz1/0vrz3DxJc/r'
HTTP/1.1 200 OK
Bearer: 5A2tPbDOXrQSMH1WzsEhhAgjsNRUhdJ6MZkah4PAU8840fSkebzmJpooRIkcc3csBafqjm5tR+nPbnydN1N378bXQtxvKr6m5doHp/rhCYYF+PbR72NE37Q/DpRgg577
Cache-Control: max-age=0, private, must-revalidate
Connection: Keep-Alive
Content-Length: 196
Content-Type: application/json; charset=utf-8
Date: Mon, 01 Jun 2015 00:23:03 GMT
Etag: W/"a710bcbfd462f6c4f7fed6bd7cff32b5"
Expires: Mon, 01 Jun 2015 01:23:03 GMT
Server: WEBrick/1.3.1 (Ruby/2.2.2/2015-04-13)
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Request-Id: 45ee363e-5df5-4514-b625-d4eb1dcb2e2a
X-Runtime: 0.024450
X-Xss-Protection: 1; mode=block

{
    "created_at": "2015-06-01T00:08:46.308Z",
    "email": "john@example.com",
    "id": 1,
    "password_digest": "$2a$10$ayl6Yj.Hu1s.sba11YuMpOwDX.fZ.zsj.lPAvyapgLf6FWZtin.FW",
    "updated_at": "2015-06-01T00:08:46.308Z"
}
```

Notice that a new bearer is returned every time you call `access_token.update(current_user)`.

If you're using Redis or Memcached store, you can't use the same bearer twice.

```
$ http GET localhost:3000/profile Authorization:'Bearer 5A2tPbDOXrQSMH1WzsEhhPaw4rNa1sJ9j7OyAU6gr1kfaZM0xDiXUGuENKyKLC/rKuzhrDXG6FwehWhIWy3IMfhQ9n6FJwBCERlF1TavYo2lG0UM8Bz1/0vrz3DxJc/r'
HTTP/1.1 401 Unauthorized
Cache-Control: no-cache
Connection: Keep-Alive
Content-Length: 0
Content-Type: text/plain; charset=utf-8
Date: Mon, 01 Jun 2015 00:23:23 GMT
Server: WEBrick/1.3.1 (Ruby/2.2.2/2015-04-13)
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Request-Id: 401c9b61-824c-44a0-8cd2-faab545127cc
X-Runtime: 0.024320
X-Xss-Protection: 1; mode=block
```

Also, check out the `examples` directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/fnando/access_token/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
