class Api::V1::MerchantsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotDestroyed, with: :render_unprocessable_entity 
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  def index
      merchants = Merchant.all
      options = {}

      if params[:sorted] == 'age'
          merchants = merchants.order(:created_at)
          options[:meta] = {count: merchants.count}
          render json: MerchantSerializer.new(merchants, options)

      elsif params[:status] == 'returned'
          merchants = Merchant.joins(:invoices).where(invoices: { status: 'returned' }).distinct
          options[:meta] = {count: merchants.count}
          render json: MerchantSerializer.new(merchants, options)

      elsif params[:count] == 'true'
          options[:meta] = {count: merchants.count}
          render json: MerchantSerializer.new(merchants, options.merge({params: {item_count: params[:count]}}))

      else
          options[:meta] = {count: merchants.count}
          render json: MerchantSerializer.new(merchants, options)
      end
  end
  
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

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_params)
    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    Merchant.destroy(params[:id]) 
    head :no_content
  end

  def find
    merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%").order(:name)
    merchant = merchants.first
    # binding.pry
    render json: MerchantSerializer.new(merchant)
  end

  private

  def merchant_params
    params.require(:merchant).permit(:name)
  end

  def render_unprocessable_entity(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :unprocessable_entity
  end

  def record_not_found(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :not_found
  end
end