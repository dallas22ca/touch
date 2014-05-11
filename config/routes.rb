Rails.application.routes.draw do
  
  devise_for :users
  
  authenticate :user do
    scope "/:permalink" do
      get "/attendance" => "modules#attendance", as: :attendance
      get "/permissions" => "modules#permissions", as: :permissions
      post "/track" => "modules#presence", as: :track
      
      resources :members, path: :contacts
      resources :segments
      resources :rooms, path: :attendance do
        resources :meetings
      end
      
      delete "/sign_out" => "devise/sessions#destroy", as: :org_signout
      get "/sign-in" => "devise/sessions#new", as: :org_signin
      get "/sign-up" => "devise/registrations#new", as: :org_signup
    end
    
    get "/:permalink" => "modules#redirect"
  end
  
  root to: "modules#redirect"
  
end
