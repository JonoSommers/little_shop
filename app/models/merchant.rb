class Merchant < ApplicationRecord
    has_many :invoices
    has_many :items

    def item_count
        items.count
    end
end