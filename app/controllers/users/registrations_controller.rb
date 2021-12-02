class Users::RegistrationsController < Devise::RegistrationsController
  include Users::UsersAuthenticable

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        respond_with resource
      else
        expire_data_after_sign_in!
        respond_with resource
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  private

  #def respond_with(resource, _opts = {})
  #  # Return token to client to be use in future request
  #  puts resource.inspect
  #  render json: {id: resource.id, email: resource.email, user_token: "Bearer #{current_token}"}
  #end
  #
  #def current_token
  #  request.env['warden-jwt_auth.token']
  #end

  private

  def sign_up_params
    params
        .require(:user)
        .permit(:email,
                :password)
  end
end
