class Api::V1::MerchantItemsController < ApplicationController
  def index 
      merchant = Merchant.find(params[:id])
      options = {}
      options[:meta] = {count: merchant.items.count}

      render json: ItemSerializer.new(merchant.items, options)
  end
end