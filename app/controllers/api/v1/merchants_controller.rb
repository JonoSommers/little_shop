class Api::V1::MerchantsController < ApplicationController
    def index
        merchants = Merchant.all
        options = {}
        options[:meta] = {count: merchants.count}

        if params[:sorted] == 'age'
            merchants = merchants.order(:created_at)
            render json: MerchantSerializer.new(merchants, options)

        elsif params[:status] == 'returned'
            merchants = merchants.joins(items: { invoice_items: :invoice })
                           .where(invoice_items: { status: 'returned' })
                           .distinct
            render json: MerchantSerializer.new(merchants, options)

        elsif params[:count]
            render json: MerchantSerializer.new(merchants, {params: {item_count: params[:count]}})

        else
            render json: MerchantSerializer.new(merchants, options)
        end
    end

    private

    def merchant_params
        params.require(:merchant).permit(:name)
    end
end