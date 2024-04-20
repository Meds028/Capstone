class Cast < ApplicationRecord
  belongs_to :artist
  belongs_to :movie

  validates :character_name, presence: true, length: { in: 3..45 }
end
