Rails.application.routes.draw do
  
  resources :identities

  devise_scope :user do
    devise_for :users,
      controllers: {
        omniauth_callbacks: "omniauth_callbacks",
        registrations: "registrations",
        sessions: "sessions"
      }
      
    get "/users/auth/facebook/setup", to: "omniauth_callbacks#setup"
    get "/:permalink/sign-in" => "devise/sessions#new"
    get "/:permalink/sign-up" => "devise/registrations#new"
    
    authenticate :user do
      resources :organizations, only: [:new, :create]
      
      scope "/:permalink" do
        get "/permissions" => "modules#permissions", as: :permissions
        post "/track" => "rooms#presence", as: :track
        get "/my-account" => "devise/registrations#edit"
      
        resources :members
        resources :segments
        resources :events
        resources :folderships, only: :index

        resources :rooms, path: :attendance do
          resources :meetings
        end
      
        resources :folders do
          post "/tasks/sort" => "tasks#sort", as: :sort_tasks
          delete "/reset" => "folders#reset", as: :reset
          resources :tasks
          resources :homes
          resources :comments

          resources :folderships, path: :members do
            post "/accept" => "folderships#accept", as: :accept
          end
        
          resources :documents do
            get "/download" => "documents#download", as: :download
          end
        end
      end

      get "/:permalink" => "modules#redirect", as: :redirector
    end
  
    scope "/:permalink" do
      get "/accept/:token" => "folderships#accept", as: :foldership_invitation
    end
  end
  
  root to: "modules#redirect"
end
