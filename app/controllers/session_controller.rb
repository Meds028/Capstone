class SessionController < ApplicationController
  def login
  end
  def create
    user = User.authenticate(login_params[:email], login_params[:password])

    if user.nil?
      flash[:alert] = "Invalid credentials"
      redirect_to login_path
    else
      sign_in user
      redirect_to home_path
    end
  end

  def destroy
    sign_out
    redirect_to login_path
  end

  private
  def login_params
    params.require(:user).permit(:email, :password)
  end
end
