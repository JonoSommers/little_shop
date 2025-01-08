class Api::V1::MerchantsController < ApplicationController
    def index
        merchants = Merchant.all
        options = {}
        options[:meta] = {count: merchants.count}

        if params[:sorted] == 'age'
            merchants = merchants.order(:created_at)
        end

        if params[:status] == 'returned'
            
        end

        if params[:count]
            render json: MerchantSerializer.new(merchants, {params: {item_count: params[:count]}})
        end
    end

    private

    def merchant_params
        params.require(:merchant).permit(:name)
    end
end