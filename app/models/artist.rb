class Artist < ApplicationRecord
    has_many :casts

    validates :first_name, presence: true, length: { in: 3..45 }
    validates :last_name, presence: true, length: { in: 3..45 }
end
