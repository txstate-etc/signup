Rails.application.routes.draw do
  resources :survey_responses

  resources :departments do
    get 'manage', on: :collection
  end

  resources :reservations, only: :index

  get '/sessions/download', to: 'sessions#download', as: :sessions_download
  get '/sessions/:id/reservations', to: 'sessions#reservations', as: :sessions_reservations

  resources :tags, :only => :show

  get '/topics/grid(/:year(/:month))', to: 'topics#grid', as: :grid
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

  root :to => "topics#index"
  devise_for :users
  resources :users
end
