Rails.application.routes.draw do
  resources :cities do
    member do
      post :update_temp
    end
  end
end
