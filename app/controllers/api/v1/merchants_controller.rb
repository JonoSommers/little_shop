class Api::V1::MerchantsController < ApplicationController
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

    private

    def merchant_params
        params.require(:merchant).permit(:name)
    end
end