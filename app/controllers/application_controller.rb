class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_website
  before_filter :set_cors
  before_filter :authenticate_user!, unless: :does_not_need_authorization
  before_filter :set_time_zone, if: :user_signed_in?
  before_filter :configure_devise_params, if: :devise_controller?
  before_filter :set_organization, if: :devise_controller?
  
  def set_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  
  def configure_devise_params
    set_organization
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:time_zone, :invitation_token, :remember_me, :name, :email, :password, :password_confirmation, organizations_attributes: [:id, :permalink, :name]) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:invitation_token, :remember_me, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:time_zone, :name, :email, :password, :password_confirmation, :current_password, :phone, :website, :avatar, organizations_attributes: [:id, :permalink, :name, :logo, :website, :full_address]) }
  end
  
  def set_time_zone
    Time.zone = current_user.time_zone
  end
  
  def after_sign_in_path_for(user)
    if params[:permalink]
      root_path
    else
      super
    end
  end
  
  def does_not_need_authorization
    %w[accept unsubscribe open click example track sms voice bitly members_save events_save].include?(action_name)
  end
  
  def set_organization
    if does_not_need_authorization || !user_signed_in?
      @org = Organization.where(permalink: params[:permalink]).first
    else
      if params[:permalink]
        @org = current_user.organizations.where(permalink: params[:permalink]).first
      else
        @org = current_user.organizations.first
      end
    
      set_member
    end
  end
  
  def set_member
    @member = current_user.members.where(organization_id: @org.id).first if @org
  end
  
  def set_website
    cookies[:domain] = Rails.env.production? ? request.domain : "realtxn.com"
    @website = CONFIG["sites"][cookies[:domain]]
    redirect_to "https://app.touchbasenow.com" unless @website
  end
  
  def redirect_to_root
    redirect_to root_path
  end
  
  def redirect_to_folder
    redirect_to folder_path(@org, @folder)
  end
  
  def set_folder
    if @member
      id = params[:folder_id] ? params[:folder_id] : params[:id]
      @foldership = @member.folderships.accepted.where(folder_id: id).first
      @folder = @foldership.folder if @foldership
    else
      redirect_to root_path
    end
  end
  
  def set_permissions
    foldership_required = %w[comments folder_tasks homes documents folderships]
    permitter = foldership_required.include?(controller_name) ? @foldership : @member
    redirect_to root_path if !permitter || !permitter.permits?(controller_name, action_type)
  end
  
  def action_type
    if %w[index show download].include? action_name
      :read
    elsif %w[new create edit update sort presence import].include? action_name
      :write
    elsif %w[destroy reset].include? action_name
      :delete
    else
      action_name.to_sym
    end
  end
  helper_method :action_type
end
