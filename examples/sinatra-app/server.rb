require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'sample.sqlite3'
)

class User < ActiveRecord::Base
  has_secure_password
end

ActiveRecord::Schema.define(version: 0) do
  next if table_exists?(:users)

  create_table :users do |t|
    t.string :email, null: false
    t.string :password_digest, null: false
    t.timestamps null: false
  end

  add_index :users, :email, unique: true
  User.create!(email: 'john@example.com', password: 'test')
end

class BaseEndpoint < Sinatra::Application
  helpers do
    def access_token
      @access_token ||= AccessToken.new(
        request: request,
        response: response,
        secret: '220c6a866bff52edc0825ee5e15be8f02953764cb7a8d54ba44b46c26a7fa8867d8aa09cc11f23843d72819d98823248e1a6dcd52abc0783cace5de459dd43dd7d8da6313cbebacb475e099c0686d210cf51636800206a19526844ab8ced6af1906a9500',
        store: AccessToken::RedisStore.new
      )
    end

    def authenticate!
      user_id = access_token.resolve
      halt(401) unless user_id

      @current_user = User.find_by_id(user_id)
      halt(401) unless @current_user
      access_token.update(current_user)
    end

    def current_user
      @current_user
    end
  end

  before do
    content_type 'application/json'
  end
end

class ProfileEndpoint < BaseEndpoint
  before { authenticate! }

  get '/profile' do
    current_user.to_json
  end
end

class AuthEndpoint < BaseEndpoint
  post '/auth' do
    user = User.find_by_email(params[:email].to_s)
            .try(:authenticate, params[:password].to_s)

    halt(401) unless user
    access_token.update(user)
    user.to_json
  end
end

App = Rack::Cascade.new([
  AuthEndpoint,
  ProfileEndpoint
])
