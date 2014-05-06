Rails.application.routes.draw do
  
  resources :meetings

  devise_for :users
  
  get "/:permalink/contacts" => "modules#contacts", as: :contacts
  get "/:permalink/attendance" => "modules#attendance", as: :attendance
  
  scope "/:permalink" do
    resources :rooms, path: :attendance
  end
  
  root to: "modules#redirect"
  
end
