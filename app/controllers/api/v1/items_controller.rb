class Api::V1::ItemsController < ApplicationController
    def index
        items = Item.all
        options = {}
        options[:meta] = {count: items.count}

        if params[:sorted] == 'price'
            items = items.order(:unit_price)
        end

        render json: ItemSerializer.new(items, options)
    end
end