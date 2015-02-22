Rails.application.routes.draw do
  namespace :kakaku do
    resources :items, only: [:show]
  end
end
