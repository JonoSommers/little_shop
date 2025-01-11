class Api::V1::InvoicesController < ApplicationController

    def index
        invoices = Invoice.all
        merchants = Merchant.all
        options = {}
        options[:meta] = {count: invoices.count}
        invoices = Invoice.joins(:merchant).where(merchant: {id: params[:merchant_id]}).distinct
        invoices = invoices.where(status: params[:status])
        render json: InvoiceSerializer.new(invoices, options)
    end
end