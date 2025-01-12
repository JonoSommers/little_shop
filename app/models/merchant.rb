class Merchant < ApplicationRecord
    has_many :items, dependent: :destroy
    has_many :invoices, dependent: :destroy

    validates :name, presence: { message: "is required and cannot be blank" }
end