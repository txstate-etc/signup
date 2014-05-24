Rails.application.routes.draw do
  resources :survey_responses

  resources :reservations

  resources :sessions

  resources :departments

  resources :topics

  root :to => "visitors#index"
  devise_for :users
  resources :users
end
