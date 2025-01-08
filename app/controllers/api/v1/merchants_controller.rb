class Api::V1::MerchantsController < ApplicationController

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id])).serializable_hash
  end

end