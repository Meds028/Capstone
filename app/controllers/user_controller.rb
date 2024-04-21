class UserController < ApplicationController
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  
  def register
    @user = User.new
  end

  def create
    if User.any?
      user_type = 0
    else
      user_type = 2
    end

    @user = User.new(user_params)
    @user.user_type = user_type

    if @user.save
      redirect_to register_path, notice: 'User was successfully created. Please log in.'
    else
      flash[:alert] = @user.errors.full_messages
      redirect_to register_path
    end
  end

  def admin_list
    @admins = User.where(user_type: [1, 2])
  end

  def create_admin
    user = User.find_by(email: user_params[:email])
  
    if user.nil?
      flash[:alert] = "Email not found"
    else
  
      if user.update_column(:user_type, user_params[:user_type])
        flash[:notice] = "Email added to admins"
      else
        flash[:alert] = "Error"
      end
    end
    
    redirect_to admins_path
  end

  def delete_admin
    user = User.find_by(email: user_params[:email])
  
    if user.nil?
      flash[:alert] = "Invalid email"
    elsif user.update_column(:user_type, 0)
      flash[:notice] = "Email removed from admins"
    else
      flash[:alert] = "Error"
    end
    redirect_to admins_path
  end

  def profile
    @user_info = User.find(session[:user_id])
  end

  def change_first_name
    user = User.find(session[:user_id])
    new_first_name = user_params[:first_name]
  
    # Check the length of the new first_name
    if new_first_name.length.between?(3, 45)
      user.update_columns(first_name: new_first_name)
      flash[:notice] = 'Profile updated successfully'
      redirect_to profile_path
    else
      # Add an error message to the user object
      user.errors.add(:first_name, "must be between 3 and 45 characters")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
    end
  end

  def change_last_name
    user = User.find(session[:user_id])
    new_last_name = user_params[:last_name]
  
    if new_last_name.length.between?(3, 45)
      user.update_columns(last_name: new_last_name)
      flash[:notice] = 'Profile updated successfully'
      redirect_to profile_path
    else
      user.errors.add(:last_name, "must be between 3 and 45 characters")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
    end
  end

  def change_email
    user = User.find(session[:user_id])
    new_email = user_params[:email]

    if new_email.length.between?(3, 45) && new_email =~ EMAIL_REGEX
      if User.where.not(id: user.id).where(email: new_email).exists?
        flash[:alert] = 'Email already in use'
        redirect_to profile_path
        return
      end

      user.update_columns(email: new_email)
      flash[:notice] = 'Profile updated successfully'
      redirect_to profile_path
    else
      user.errors.add(:email, "must be between 3 and 45 characters and have a valid format")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
    end
  end

  def change_password
    user = User.find(session[:user_id])
    old_password = user_params[:password]
    new_password = user_params[:new_password]
    confirm_password = user_params[:password_confirmation]
  
    hashed_old_password = Digest::SHA2.hexdigest("#{user.salt}--#{old_password}")
  
    puts "Submitted old password: #{old_password}"
    puts "Hashed old password: #{hashed_old_password}"
  
    if hashed_old_password != user.password
      user.errors.add(:old_password, "is incorrect")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
      return
    end
  
    if !new_password.length.between?(6, 16)
      user.errors.add(:new_password, "must be between 6 and 16 characters")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
      return
    end
  
    if new_password != confirm_password
      user.errors.add(:confirm_password, "does not match the new password")
      flash[:alert] = user.errors.full_messages
      redirect_to profile_path
      return
    end
  
    new_salt = Digest::SHA2.hexdigest("#{Time.now.utc}--#{new_password}")
    new_hashed_password = Digest::SHA2.hexdigest("#{new_salt}--#{new_password}")
  
    if user.update_columns(password: new_hashed_password, salt: new_salt)
      flash[:notice] = 'Password updated successfully'
    else
      flash[:alert] = 'Failed to update password'
    end
  
    redirect_to profile_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :new_password, :password_confirmation, :user_type)
  end
end
