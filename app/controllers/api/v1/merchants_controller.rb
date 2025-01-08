class Api::V1::MerchantsController < ApplicationController
    def index
        merchants = Merchant.all
        options = {}
        options[:meta] = {count: merchants.count}

        if params[:sorted] == 'age'
            merchants = merchants.order(:created_at)
        end

        render json: MerchantSerializer.new(merchants, options)
    end
end