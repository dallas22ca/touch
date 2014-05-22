class RegistrationsController < Devise::RegistrationsController
  def new
    build_resource {}

    if params[:token]
      foldership = Foldership.where(token: params[:token]).first
      resource.name = foldership.name
      resource.email = foldership.email
    end
    
    if foldership && foldership.accepted?
      render text: "This invitation has already been accepted."
    else
      respond_with self.resource
    end
  end

  def create
    build_resource(sign_up_params)

    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  
  def update
    @user = User.find(current_user.id)
    params[:user].delete(:current_password)

    if @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
      set_flash_message :notice, :updated
      sign_in @user, bypass: true
      redirect_to root_path
    else
      render "edit"
    end
  end
end 