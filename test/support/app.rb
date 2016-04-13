require "sinatra/base"

class User < ActiveRecord::Base
  has_secure_password
end

class BaseEndpoint < Sinatra::Application
  helpers do
    def access_token
      @access_token ||= AccessToken.new(
        request: request,
        response: response,
        secret: "26aa6785e075754ea4f2f77d9edee74b1fd8218a",
        store: AccessToken::RedisStore.new
      )
    end

    def authenticate!
      user_id = access_token.resolve
      halt(401) unless user_id

      @current_user = User.find_by_id(user_id)
      halt(401) unless @current_user
    end

    def current_user
      @current_user
    end
  end

  before do
    content_type "application/json"
  end
end

class AuthEndpoint < BaseEndpoint
  post "/auth" do
    user = User.find_by_email(params[:email].to_s)
            .try(:authenticate, params[:password].to_s)

    halt(401) unless user
    access_token.update(user)
    user.to_json
  end
end

class ProfileEndpoint < BaseEndpoint
  before do
    authenticate!
  end

  get "/profile" do
    current_user.to_json
  end
end

App = Rack::Cascade.new([
  AuthEndpoint,
  ProfileEndpoint
])
