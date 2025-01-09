class Api::V1::MerchantsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  
  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id])).serializable_hash
  end

  def create
    merchant = Merchant.new(merchant_params)
    if merchant.valid?
      merchant.save
      render json: MerchantSerializer.new(merchant), status: :created
    else
      render json: { message: 'Validation Failed', errors: merchant.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    render json: Merchant.destroy(params[:id])
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def render_unprocessable_entity(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :unprocessable_entity
  end
end