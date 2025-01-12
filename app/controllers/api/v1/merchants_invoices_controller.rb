class Api::V1::MerchantsInvoicesController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :invalid_merchant_id

    def index
        invoices = Invoice.all
        options = {}
        merchant = Merchant.find(params[:merchant_id])
        merchant_invoices = invoices.where(merchant_id: params[:merchant_id])
        if !params[:status].present?
            options[:meta] = {count: merchant_invoices.count}
            render json: InvoiceSerializer.new(merchant_invoices, options)

        elsif params[:status].present?
            target_invoices = invoices.where(merchant_id: params[:merchant_id], status: params[:status])
            options[:meta] = {count: target_invoices.count}
            render json: InvoiceSerializer.new(target_invoices, options)
        end
    end

    private

    def invoice_params
        params.require(:invoice).permit(:customer_id, :merchant_id, :status)
    end

    def invalid_merchant_id(exception)
        render json: { message: exception.message, errors: [exception.message] }, status: :not_found
    end
end