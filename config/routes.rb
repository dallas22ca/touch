Rails.application.routes.draw do
  
  devise_for :users
  
  authenticate :user do
    get "/:permalink/contacts" => "modules#contacts", as: :contacts
    get "/:permalink/attendance" => "modules#attendance", as: :attendance
  
    scope "/:permalink" do
      post "/track" => "modules#presence", as: :track
    
      resources :rooms, path: :attendance do
        resources :meetings
      end
    end
    
    get "/:permalink" => "modules#redirect"
  end
  
  root to: "modules#redirect"
  
end
