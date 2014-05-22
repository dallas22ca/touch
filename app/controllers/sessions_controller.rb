class SessionsController < Devise::SessionsController
  def new
    foldership = Foldership.where(token: params[:token]).first if params[:token]
    
    if foldership && foldership.accepted?
      render text: "This invitation has already been accepted."
    else
      super
    end
  end
  
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    
    if params[:user][:invitation_token]
      resource.invitation_token = params[:user][:invitation_token]
      resource.accept_invitation
    end
    
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end 