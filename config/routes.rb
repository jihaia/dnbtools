Rails.application.routes.draw do

  resources :welcomes
  get 'welcome', to: 'welcome#index'

end
