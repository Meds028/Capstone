class WebsiteController < ApplicationController
  def homepage
    user = User.find(session[:user_id])
    @carousel_movies = Movie.order(release_year: :desc, created_at: :desc).limit(6)
    @latest_movies = Movie.order(release_year: :desc, created_at: :desc).limit(18)
    @top_picks = Movie.joins(:watchlists).group('movies.id').order('COUNT(watchlists.id) DESC').limit(18)
    @watchlist_movies = user.movies.limit(18)

    @top_rated_movies = Movie.all
    @top_rated_movies.each do |movie|
      movie.average_rating = movie.ratings.average(:rate)
    end
    @top_rated_movies = @top_rated_movies.sort_by { |movie| -movie.average_rating.to_f }.first(18)
  end

  def browse
    if params[:param] == "top_picks"
      @movies = Movie.joins(:watchlists).group('movies.id').order('COUNT(watchlists.id) DESC')
      render 'browse'
    elsif params[:param] == "lastest"
      @movies = Movie.order(release_year: :desc, created_at: :desc)
      render 'browse'
    else
      @movies = Movie.all
      render 'browse'
    end
  end

  def search
    @movies = Movie.where("LOWER(title) LIKE ?", "%#{params[:param].downcase}%")

    render 'browse'
  end

  def watchlist
    user = User.find(session[:user_id])
    @watchlist_movies = user.movies
    @added_dates = Watchlist.where(user_id: session[:user_id]).group_by(&:movie_id)
  end

  def add_watchlist
    watchlist = Watchlist.find_by(movie_id: movie_params[:movie_id], user_id: session[:user_id])
    add = Watchlist.new(movie_id: movie_params[:movie_id], user_id: session[:user_id])
  
    if add.save
      flash[:notice] = "Successfully Added to Watchlist"
    else
      flash[:alert] = "Failed to Add in Watchlist"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end 

  def remove_watchlist
    watchlist = Watchlist.find_by(movie_id: movie_params[:movie_id], user_id: session[:user_id])

    if watchlist
      watchlist.destroy
      flash[:notice] = "Successfully removed from Watchlist"
    else
      flash[:alert] = "Record not found"
    end
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def remove_watchlists
    watchlist = Watchlist.find_by(movie_id: movie_params[:movie_id], user_id: session[:user_id])

    if watchlist
      watchlist.destroy
      flash[:notice] = "Successfully removed from Watchlist"
    else
      flash[:alert] = "Record not found"
    end
    redirect_to watchlist_path
  end

  def movie_info
    @watchlist = Watchlist.find_by(movie_id: params[:id], user_id: session[:user_id])
    @movie = Movie.find(params[:id])
    @latest_movies = Movie.order(release_year: :desc, created_at: :desc).limit(21)
    @artist_lists = Artist.all.order(:last_name)
    movies = Movie.includes(casts: :artist).find(params[:id])
    @cast_lists = movies.casts.limit(6)
    @genres = Genre.all
    genres = Movie.includes(movie_genres: :genre).find(params[:id])
    @saved_genre = genres.movie_genres

    if current_user.user_type == 0
      @partial_name = 'movie_info_regular'
    else
      @partial_name = 'movie_info_admin'
    end
  end

  def movie_info_regular
  end
  def movie_info_admin
  end
  
  def add_movie
    @movie = Movie.new
    @countries = Country.all
  end

  def create_movie
    @movie = Movie.new(movie_params)

    if @movie.save
      flash[:notice] = 'Movie was successfully created.'
      redirect_to add_movies_path
    else
      flash[:alert] = @movie.errors.full_messages
      redirect_to add_movies_path
    end
  end

  def change_title
    movie = Movie.find(movie_params[:movie_id])

    if movie_params[:title].length.between?(3, 45)
      movie.update(title: movie_params[:title])
      flash[:notice] = 'Movie updated successfully'
    else
      flash[:alert] = "Title must be between 3 and 45 characters"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def change_year
    movie = Movie.find(movie_params[:movie_id])

    if movie_params[:release_year].length == 4 && movie_params[:release_year].match?(/^\d+$/)
      movie.update(release_year: movie_params[:release_year])
      flash[:notice] = 'Movie updated successfully'
    elsif movie_params[:release_year].length != 4
      flash[:alert] = "Release year must be 4 digits long"
    else
      flash[:alert] = "Release year must contain only numbers"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def change_summary
    movie = Movie.find(movie_params[:movie_id])

    if movie_params[:summary].present?
      movie.update(summary: movie_params[:summary])
      flash[:notice] = 'Movie updated successfully'
    else
      flash[:alert] = "Title must be between 3 and 45 characters"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def change_trailer
    movie = Movie.find(movie_params[:movie_id])

    if movie_params[:trailer].present?
      movie.update(trailer: movie_params[:trailer])
      flash[:notice] = 'Movie updated successfully'
    else
      flash[:alert] = "Trailer link must be present"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def change_poster
    movie = Movie.find(movie_params[:movie_id])

    if movie_params[:poster].present?
      movie.update(poster: movie_params[:poster])
      flash[:notice] = 'Movie updated successfully'
    else
      flash[:alert] = "Poster link must be present"
    end
  
    redirect_to movie_info_path(movie_params[:movie_id])
  end

  def add_artist
    artist = Artist.new(first_name: cast_params[:first_name], last_name: cast_params[:last_name])

    if artist.save
      flash[:notice] = 'Artist successfully added'
    else
      flash[:alert] = artist.errors.full_messages
    end
    redirect_to movie_info_path(cast_params[:movie_id])
  end

  def remove_artist
    artist = Artist.find(cast_params[:artist_id])

    if artist.destroy
      flash[:notice] = 'Artist successfully removed'
    else
      flash[:alert] = artist.errors.full_messages
    end
    
    redirect_to movie_info_path(cast_params[:movie_id])
  end
  
  def add_cast
    cast = Cast.new(character_name: cast_params[:character_name], movie_id: cast_params[:movie_id], artist_id: cast_params[:artist_id])

    if cast.save
      flash[:notice] = 'Artist successfully added'
    else
      flash[:alert] = artist.errors.full_messages
    end
    redirect_to movie_info_path(cast_params[:movie_id])
  end

  def remove_cast
    artist = Artist.find(cast_params[:artist_id])

    if artist.destroy
      flash[:notice] = 'Artist successfully removed'
    else
      flash[:alert] = artist.errors.full_messages
    end
    
    redirect_to movie_info_path(cast_params[:movie_id])
  end

  def add_rate
    rating = Rating.find_or_initialize_by(movie_id: rate_params[:movie_id], user_id: session[:user_id])
    
    if rating.update(rate: rate_params[:rate])
      flash[:notice] = 'Rated'
    else
      flash[:alert] = 'Error'
    end
    
    redirect_to movie_info_path(rate_params[:movie_id])
  end

  def add_genre
    movie = Movie.find(genre_params[:movie_id])
    genre = Genre.find(genre_params[:genre_id])
  
    # Check if the genre is already associated with the movie
    if movie.genres.include?(genre)
      flash[:alert] = 'Genre already added'
    else
      movie_genre = MovieGenre.new(movie: movie, genre: genre)
    
      if movie_genre.save
        flash[:notice] = 'Genre successfully added'
      else
        flash[:alert] = "Genre failed to add: #{movie_genre.errors.full_messages.join(', ')}"
      end
    end
    
    redirect_to movie_info_path(id: genre_params[:movie_id])
  end
  
  
  def remove_genre
    movie_genre = MovieGenre.find_by(id: genre_params[:saved_genre_id])
  
    if movie_genre && movie_genre.destroy
      flash[:notice] = 'Genre successfully removed'
    else
      flash[:alert] = 'Genre failed to be removed'
    end
  
    redirect_to movie_info_path(genre_params[:movie_id])
  end
  
  

  private

  def movie_params
    params.require(:movie).permit(:title, :release_year, :summary, :trailer, :poster, :country_id, :movie_id)
  end

  def cast_params
    params.require(:cast).permit(:character_name, :first_name, :last_name, :movie_id, :cast_id, :artist_id)
  end

  def rate_params
    params.require(:rate).permit(:rate, :movie_id)
  end

  def genre_params
    params.require(:genre).permit(:saved_genre_id, :genre_id, :movie_id)
  end

  def browse_params
    params.require(:genre).permit(:type)
  end
end


# <div id="top_rated_movies">
#             <a href="#"><h1>Top Rated</h1></a>
#             <div id="top_rate" class="carousel slide carousel-dark" data-bs-ride="carousel">
#                 <div class="carousel-inner">
#                     <% @top_rated_movies.each_slice(6).with_index do |movies_slice, index| %>
#                         <div class="carousel-item <%= index == 0 ? 'active' : '' %>" data-bs-interval="5000">
#                             <div class="row">
#                                 <% movies_slice.each do |movie| %>
#                                     <div class="col-md-4">
#                                         <div class="card">
#                                             <img src="<%= movie.poster %>" class="card-img-top" alt="<%= movie.title %>">
#                                             <div class="card-body">
#                                                 <h5 class="card-title"><%= movie.title %></h5>
#                                                 <p class="card-text">Release Year: <%= movie.release_year %></p>
#                                                 <p class="card-text">Summary: <%= movie.summary %></p>
#                                                 <p class="card-text">Average Rating: <%= movie.average_rating&.round(1) || 'N/A' %></p>
#                                                 <a href="#" class="btn btn-primary">Go somewhere</a>
#                                             </div>
#                                         </div>
#                                     </div>
#                                 <% end %>
#                             </div>
#                         </div>
#                     <% end %>
#                 </div>
                
#                 <button class="carousel-control-prev prev_button" type="button" data-bs-target="#top_rate" data-bs-slide="prev">
#                     <span class="carousel-control-prev-icon" aria-hidden="true"></span>
#                     <span class="visually-hidden">Previous</span>
#                 </button>
#                 <button class="carousel-control-next next_button" type="button" data-bs-target="#top_rate" data-bs-slide="next">
#                     <span class="carousel-control-next-icon" aria-hidden="true"></span>
#                     <span class="visually-hidden">Next</span>
#                 </button>
#             </div>
#         </div>