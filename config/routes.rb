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
      
      resources :folders do
        post "/tasks/sort" => "tasks#sort", as: :sort_tasks
        resources :tasks
        resources :homes
        
        resources :documents do
          get "/download" => "documents#download", as: :download
        end
      end
    end
    
    get "/:permalink" => "modules#redirect"
  end
  
  root to: "modules#redirect"
  
end
