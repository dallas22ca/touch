Rails.application.routes.draw do
  
  devise_scope :user do
    devise_for :users
    
    authenticate :user do
      scope "/:permalink" do
        get "/attendance" => "modules#attendance", as: :attendance
        get "/permissions" => "modules#permissions", as: :permissions
        post "/track" => "modules#presence", as: :track
      
        resources :members, path: :contacts
        resources :segments
        resources :folderships, only: :index

        resources :rooms, path: :attendance do
          resources :meetings
        end
      
        resources :folders do
          post "/tasks/sort" => "tasks#sort", as: :sort_tasks
          resources :tasks
          resources :homes

          resources :folderships, except: :index do
            post "/accept" => "folderships#accept", as: :accept
          end
        
          resources :documents do
            get "/download" => "documents#download", as: :download
          end
        end
      end

      get "/:permalink" => "modules#redirect"
    end
  
    scope "/:permalink" do
      get "/accept/:token" => "folderships#accept", as: :foldership_invitation
    end
  end
  
  root to: "modules#redirect"
end
