class Api::V1::ItemsMerchantController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  def index
    item = Item.find(params[:id])

    render json: MerchantSerializer.new(item.merchant)
  end

  private

  def record_not_found(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :not_found
  end
end