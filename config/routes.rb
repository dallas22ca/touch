Rails.application.routes.draw do
  
  devise_for :users
  
  authenticate :user do
    scope "/:permalink" do
      get "/attendance" => "modules#attendance", as: :attendance
      get "/permissions" => "modules#permissions", as: :permissions
      post "/track" => "modules#presence", as: :track
      
      resources :members, path: :contacts
      resources :rooms, path: :attendance do
        resources :meetings
      end
    end
    
    get "/:permalink" => "modules#redirect"
  end
  
  root to: "modules#redirect"
  
end
