class Api::V1::MerchantsCustomersController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    customers = Customer.joins(:invoices).where(invoices: { merchant: merchant.id }).distinct

    render json: CustomerSerializer.new(customers)
  end
end