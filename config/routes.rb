Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post "users/register", to: "users#register"
  post "users/login", to: "users#login"

  post "files/upload", to: "files#upload"
  post "files/:id/share", to: "files#share"
  get "files", to: "files#index"
end
