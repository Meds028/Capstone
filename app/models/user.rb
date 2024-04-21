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
