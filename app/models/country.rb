class Country < ApplicationRecord
    has_many :movies

    validates :name, presence: true, uniqueness: true
end
