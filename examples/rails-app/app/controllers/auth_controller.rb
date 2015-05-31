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
