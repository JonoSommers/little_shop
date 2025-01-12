class Api::V1::MerchantItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  def index 
      merchant = Merchant.find(params[:id])
      options = {}
      options[:meta] = {count: merchant.items.count}

      render json: ItemSerializer.new(merchant.items, options)
  end

  private

  def record_not_found(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :not_found
  end
end