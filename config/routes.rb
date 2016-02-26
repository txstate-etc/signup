Rails.application.routes.draw do
  resources :survey_responses, only: [:new, :create]

  resources :departments do
    get 'manage', on: :collection
  end

  # Need reservation/download as alias to show.ics for backwards compatability
  get '/reservations/download/:id', to: 'reservations#show', defaults: { format: 'ics' }

  # This not included below. because the index route shouldn't be nested
  resources :reservations, only: :index

  get '/sessions/download', to: 'sessions#download', as: :sessions_download
  get '/sessions/:id/reservations', to: 'sessions#reservations', as: :sessions_reservations
  get '/sessions/attendance/:id', to: redirect('/sessions/%{id}/reservations')
  post '/sessions/:id/email', to: 'sessions#email', as: :sessions_email

  resources :tags, :only => :show

  get '/topics/grid(/:year(/:month))', to: 'topics#grid', as: :grid
  get '/topics/upcoming', to: redirect('/'), as: :upcoming
  get '/topics/download/:id', to: 'topics#download', as: :download
  resources :topics, shallow: true do
    resources :sessions, except: :index do
      resources :reservations, except: [:index, :new] do
        member do
          get 'certificate'
          get 'send_reminder'
        end
      end
      member do
        get 'survey_results'
        get 'survey_comments/:which', to: 'sessions#survey_comments', which: /(most_useful|general)/
      end
    end
    member do
      get 'history'
      get 'survey_results'
      get 'survey_comments/:which', to: 'topics#survey_comments', which: /(most_useful|general)/
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

  get '/auth/:provider/callback', to: 'auth_sessions#create'
  get '/logout', to: 'auth_sessions#destroy', as: 'logout'

  root :to => 'topics#index'

  unless Rails.env.production?
    get '/test', to: 'test#index'
  end

end
