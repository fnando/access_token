Rails.application.routes.draw do
  get '/profile', to: 'profile#show'
  post '/auth', to: 'auth#create'
end
