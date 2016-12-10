Rails.application.routes.draw do

    root to: 'dashboard#index'

    devise_for :admins, controllers: {
        sessions: 'admins/sessions',
        passwords:'admins/passwords'
    }


    devise_for :users, controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations'
    }

    namespace :admins do

      get 'dashboard', to: 'dashboard#index'

    end

    # ERROR HANDLERS
end
