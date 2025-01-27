Spree::Core::Engine.add_routes do
  scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do
    devise_for :spree_user,
              class_name: Spree.user_class.to_s,
              controllers: { sessions: 'spree/user_sessions',
                                registrations: 'spree/user_registrations',
                                passwords: 'spree/user_passwords',
                                confirmations: 'spree/user_confirmations' },
              skip: [:unlocks, :omniauth_callbacks],
              path_names: { sign_out: 'logout' },
              path_prefix: :user

    devise_scope :spree_user do
      get '/logout' => 'user_sessions#destroy', :as => :logout

      if Spree::Auth::Config[:database_authenticatable]
        get '/login' => 'user_sessions#new', :as => :login
        post '/login' => 'user_sessions#create', :as => :create_new_session

        get '/password/change' => 'user_passwords#edit', :as => :edit_password
        put '/password/change' => 'user_passwords#update', :as => :update_password
      end

      if Spree::Auth::Config[:registerable]
        get '/signup' => 'user_registrations#new', :as => :signup
        post '/signup' => 'user_registrations#create', :as => :registration
      end

      if Spree::Auth::Config[:recoverable]
        get '/password/recover' => 'user_passwords#new', :as => :recover_password
        post '/password/recover' => 'user_passwords#create', :as => :reset_password
      end

      if Spree::Auth::Config[:confirmable]
        get '/confirm' => 'user_confirmations#show', :as => :confirmation
      end
    end

    if Spree::Core::Engine.frontend_available?
      resources :users, only: [:edit, :update]
      get '/checkout/registration' => 'checkout#registration', :as => :checkout_registration
      put '/checkout/registration' => 'checkout#update_registration', :as => :update_checkout_registration
      resource :account, controller: 'users'
    end

    if Spree.respond_to?(:admin_path) && Spree::Core::Engine.backend_available?
      namespace :admin, path: Spree.admin_path do
        devise_for :spree_user,
                  class_name: Spree.admin_user_class.to_s,
                  controllers: { sessions: 'spree/admin/user_sessions',
                                   passwords: 'spree/admin/user_passwords' },
                  skip: [:unlocks, :omniauth_callbacks, :registrations],
                  path_names: { sign_out: 'logout' },
                  path_prefix: :user

        devise_scope :spree_user do
          get '/authorization_failure', to: 'user_sessions#authorization_failure', as: :unauthorized
          get '/login' => 'user_sessions#new', :as => :login
          post '/login' => 'user_sessions#create', :as => :create_new_session
          get '/logout' => 'user_sessions#destroy', :as => :logout
          get '/password/recover' => 'user_passwords#new', :as => :recover_password
          post '/password/recover' => 'user_passwords#create', :as => :reset_password
          get '/password/change' => 'user_passwords#edit', :as => :edit_password
          put '/password/change' => 'user_passwords#update', :as => :update_password
        end
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        resource :account, controller: :account, only: %i[show create update]
        resources :account_confirmations, only: %i[show]
        resources :passwords, controller: :passwords, only: %i[create update]
      end
    end
  end
end
