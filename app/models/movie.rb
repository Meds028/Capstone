class Movie < ApplicationRecord
  has_many :watchlists, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :movie_genres, dependent: :destroy
  has_many :genres, through: :movie_genres
  has_many :casts, dependent: :destroy
  has_many :artists, through: :casts, dependent: :destroy
  has_many :users, through: :ratings, dependent: :destroy
  belongs_to :country, dependent: :destroy

  validates :title, presence: true, length: { minimum: 6 }
  validates :release_year, presence: true, length: { is: 4 }, format: { with: /\A\d{4}\z/, message: "only allows numbers" }
  validates :summary, presence: true, length: { minimum: 12 }
  validates :trailer, presence: true, length: { minimum: 6 }

  def average_ratings
    ratings.average(:rate)&.round(1) || 'N/A'
  end
  attr_accessor :average_rating
end
