class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def setup
    req = Rack::Request.new(env)
    request.env['omniauth.strategy'].options[:client_id] = @website["facebook_app_id"]
    request.env['omniauth.strategy'].options[:client_secret] = @website["facebook_app_secret"]
    render text: "Omniauth setup phase.", status: 404
  end
      
  def all
    user = User.from_omniauth(request.env["omniauth.auth"], @website["domain"])
    if user.persisted?
      flash.notice = "Signed in!"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end
  alias_method :facebook, :all
end