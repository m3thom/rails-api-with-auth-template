class Users::SessionsController < Devise::SessionsController
  include Users::UsersAuthenticable

  private

  def respond_to_on_destroy
    head :no_content
  end
end
