Rails.application.routes.draw do
  resources :survey_responses, only: [:new, :create]

  resources :departments do
    get 'manage', on: :collection
  end

  #FIXME need reservation/download as alias to show.ics for backwards compatability
  resources :reservations, only: [:index, :show]

  get '/sessions/download', to: 'sessions#download', as: :sessions_download
  get '/sessions/:id/reservations', to: 'sessions#reservations', as: :sessions_reservations
  get '/sessions/:id/email', to: 'sessions#email', as: :sessions_email

  resources :tags, :only => :show

  get '/topics/grid(/:year(/:month))', to: 'topics#grid', as: :grid
  get '/topics/upcoming', to: redirect('/'), as: :upcoming
  resources :topics, shallow: true do
    resources :sessions, except: :index do
      resources :reservations, except: [:index, :new, :show] do
        member do
          get 'certificate'
        end
      end
      member do
        get 'survey_results'
      end
    end
    member do
      get 'history'
      get 'survey_results'
      get 'download'
      get 'delete'
    end
    collection do
      get 'manage'
      get 'by-department'
      get 'by-site'
      get 'alpha'
    end
  end

  resources :users do
    collection do
      get 'autocomplete_search'
    end
  end

  get '/auth/:provider/callback', to: 'authentication#create'
  get '/logout', to: 'authentication#destroy', as: 'logout'

  root :to => 'topics#index'
end
