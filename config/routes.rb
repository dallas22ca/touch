Rails.application.routes.draw do
  
  devise_for :users
  
  get "/:permalink/contacts" => "modules#contacts", as: :contacts
  get "/:permalink/attendance" => "modules#attendance", as: :attendance
  
  scope "/:permalink" do
    resources :rooms, path: :attendance do
      resources :meetings
    end
  end
  
  root to: "modules#redirect"
  
end
