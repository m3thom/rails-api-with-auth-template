module Users::UsersAuthenticable
  extend ActiveSupport::Concern

  private

  def respond_with(resource, _opts = {})
    # Return token to client to be use in future request
    puts resource.inspect
    render json: {id: resource.id, email: resource.email, user_token: "Bearer #{current_token}"}
  end

  def current_token
    request.env['warden-jwt_auth.token']
  end
end