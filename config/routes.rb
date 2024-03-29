Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'user_sessions#new'

  get '/news' => 'pages#news', as: 'news'
  get '/usage' => 'pages#usage', as: 'usage'

  resources :applications
  resources :user_sessions, only: [ :new, :create, :destroy ]

  resources :password_reset_requests, only: [ :new, :create ]
  get  '/password_reset'  => 'password_resets#new', as: 'new_password_reset'
  get  '/password_reset/:challenge' => 'password_resets#new', as: 'password_reset_with_challenge'
  post '/password_reset'  => 'password_resets#create', as: 'password_reset'

  get '/login'            => 'user_sessions#new', as: 'login'
  get '/logout'           => 'user_sessions#destroy', as: 'logout'
  get '/dashboard'        => 'dashboard#show', as: 'dashboard'
  get '/dashboard/resources' => 'dashboard#resources', as: 'resources_dashboard'

  get  '/profile'         => 'profile#show_my_profile', as: 'my_profile'
  get  '/profile/edit'    => 'profile#edit', as: 'edit_profile'
  post '/profile/edit'    => 'profile#update'
  get  '/profile/:id'     => 'profile#show', as: 'profile'
  get  '/password/change' => 'password#edit', as: 'change_password'
  post '/password/change' => 'password#update'
  post '/cc-pull'         => 'change_control#pull', as: 'cc_pull'

  resources :projects, only: [ :index, :new, :create, :destroy, :show ] do
    member do
      get :profile
      get :manage
      get :details
    end

    resource  :profile, controller: "project_profile", only: [ :show, :edit, :update ]
    resources :members, controller: "project_members", only: [ :index, :create, :destroy ]
  end

  resources :project_joins, only: [ :new, :create ]
  resources :circles,     only: [ :index, :new, :create, :destroy ]
  resources :experiments, only: [ :index, :new, :create, :destroy, :show ] do
    member do
      get     :realize
      delete  :remove_realization
      get     :manage
      post    :clone
    end

    resources :realizations, controller: "experiment_realizations" do
      member do
        post :release
      end
    end

    resources :members, controller: "experiment_members", only: [ :index, :create, :destroy ]
    resource  :profile, controller: "experiment_profile", only: [ :show, :edit, :update ]
    resources :aspects, controller: "experiment_aspects", only: [ :new, :create, :edit, :update, :destroy ]
  end

  resources :notifications do
    collection do
      get :new_only
    end
    member do
      post :mark_as_read
    end
  end
  resources :libraries do
    collection do
      get :my
      get :other
    end

    member do
      get  :details
      post :copy_experiment
    end
  end

  resources :new_project_requests, only: :index
  resources :join_project_requests, only: :show


  namespace :admin do
    # spi log
    get     '/spi_log'      => 'spi_log#index', as: 'spi_log'
    get     '/full_spi_log' => 'spi_log#full_index', as: 'full_spi_log'
    delete  '/spi_log'      => 'spi_log#clear'

    # seeding
    get     '/seed'         => 'seeding#show'
    get     '/seed/perform' => 'seeding#perform'
  end

  get '/spi_log'      => redirect('/admin/spi_log')
  get '/full_spi_log' => redirect('/admin/full_spi_log')

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
