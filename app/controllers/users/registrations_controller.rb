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

  private

  def sign_up_params
    params
        .require(:user)
        .permit(:email,
                :password)
  end
end
