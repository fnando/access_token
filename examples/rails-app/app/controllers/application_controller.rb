class ApplicationController < ActionController::Base
  private

  def access_token
    @access_token ||= AccessToken.new(
      request: request,
      response: response,
      secret: Rails.application.secrets.access_token_secret,
      store: AccessToken::RedisStore.new,
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
