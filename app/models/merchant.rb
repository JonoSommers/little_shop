class Merchant < ApplicationRecord
    has_many :invoices
    has_many :items

    validates :name, presence: { message: "is required and cannot be blank" }
end