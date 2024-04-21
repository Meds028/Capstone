Rails.application.routes.draw do  
  get "login" => "session#login"
  get "register" => "user#register"
  post "create_user" => "user#create"
  post "login_user" => "session#create"
  get "signout" => "session#destroy"
  get "profile" => "user#profile"

  post "change_first_name" => "user#change_first_name"
  post "change_last_name" => "user#change_last_name"
  post "change_email" => "user#change_email"
  post "change_password" => "user#change_password"

  post "change/title", to: "website#change_title", as: "change_movie_title"
  post "change/year", to: "website#change_year", as: "change_movie_year"
  post "change/summary", to: "website#change_summary", as: "change_movie_summary"
  post "change/trailer", to: "website#change_trailer", as: "change_movie_trailer"
  post "change/poster", to: "website#change_poster", as: "change_movie_poster"
  post "add/rate", to: "website#add_rate", as: "add_rate"
  post "add/genre", to: "website#add_genre", as: "add_genre"
  post "remove/genre", to: "website#remove_genre", as: "remove_genre"
  post "delete/movie", to: "website#delete_movie", as: "delete_movie"

  post "add/cast", to: "website#add_cast", as: "add_movie_cast"
  post "add/artist", to: "website#add_artist", as: "add_artist"
  post "remove/artist", to: "website#remove_artist", as: "remove_artist"

  get "home" => "website#homepage"
  get "browse/:param", to: "website#browse", as: "browse"
  get "watchlist" => "website#watchlist"
  get "rated" => "website#rated"
  get "info/:id", to: "website#movie_info", as: "movie_info"
  post "watchlist/add_movie", to: "website#add_watchlist", as: "add_watchlist"
  post "watchlist/remove_movie", to: "website#remove_watchlist", as: "remove_watchlist"
  post "watchlist/remove_movies", to: "website#remove_watchlists", as: "remove_watchlists"

  get "add_movies" => "website#add_movie"
  post "create_movies" => "website#create_movie"

  get "search/:param" => "website#search"

  get "admins" => "user#admin_list"
  post "add_admin" => "user#create_admin"
  post "remove_admin" => "user#delete_admin"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
