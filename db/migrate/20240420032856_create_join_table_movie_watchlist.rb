class CreateJoinTableMovieWatchlist < ActiveRecord::Migration[7.1]
  def change
    create_join_table :movies, :watchlists do |t|
      # t.index [:movie_id, :watchlist_id]
      # t.index [:watchlist_id, :movie_id]
    end
  end
end
