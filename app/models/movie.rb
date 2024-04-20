class Movie < ApplicationRecord
  has_many :watchlists
  has_many :ratings
  has_many :movie_genres
  has_many :genres, through: :movie_genres
  has_many :casts
  has_many :artists, through: :casts
  belongs_to :country

  validates :title, presence: true, length: { minimum: 6 }
  validates :release_year, presence: true, length: { is: 4 }, format: { with: /\A\d{4}\z/, message: "only allows numbers" }
  validates :summary, presence: true, length: { minimum: 12 }
  validates :trailer, presence: true, length: { minimum: 6 }

  def average_ratings
    ratings.average(:rate)&.round(1) || 'N/A'
  end
  attr_accessor :average_rating
end
