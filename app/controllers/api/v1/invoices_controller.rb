class Api::V1::InvoicesController < ApplicationController
    def index
        invoices = Invoice.all
        options = {}
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
end