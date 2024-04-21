############## Model ##############
class User < ApplicationRecord
    has_many :watchlists
    has_many :ratings
    has_many :movies, through: :watchlists
    has_many :movies, through: :ratings

    EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
    validates :first_name, presence: true, length: { in: 3..45 }
    validates :last_name, presence: true, length: { in: 3..45 }
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
    validates :password, presence: true, length: { in: 6..32 }, confirmation: true

    before_save :hash_password

    def has_password?(submitted_password)
        hashed_submitted_password = encrypt(submitted_password)

        hashed_submitted_password == self.password
    end

    def self.authenticate(email, submitted_password)
        user = find_by_email(email)

        return nil if user.nil?
        return user if user.has_password?(submitted_password)
    end

    private

    def hash_password
        self.salt = Digest::SHA2.hexdigest("#{Time.now.utc}--#{password}") if self.new_record?
        self.password = encrypt(password)
    end

    def encrypt(pass)
        Digest::SHA2.hexdigest("#{salt}--#{pass}")
    end
end

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

class Artist < ApplicationRecord
    has_many :casts

    validates :first_name, presence: true, length: { in: 3..45 }
    validates :last_name, presence: true, length: { in: 3..45 }
end

class Cast < ApplicationRecord
    belongs_to :artist
    belongs_to :movie

    validates :character_name, presence: true, length: { in: 3..45 }
end

class Country < ApplicationRecord
    has_many :movies

    validates :name, presence: true, uniqueness: true
end

class Genre < ApplicationRecord
    has_many :movie_genres
    has_many :movies, through: :movie_genres

    validates :name, presence: true, uniqueness: true
end

class MovieGenre < ApplicationRecord
    belongs_to :movie
    belongs_to :genre
end

class Rating < ApplicationRecord
    belongs_to :user
    belongs_to :movie

    validates :rate, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
end

class Watchlist < ApplicationRecord
    belongs_to :user
    belongs_to :movie
end
