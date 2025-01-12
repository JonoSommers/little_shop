require 'rails_helper'

RSpec.describe "Invoice endpoints", type: :request do
    describe 'Invoices' do
        it 'renders a JSON representation of all invoices for a given merchant that have a status matching the desired status query parameter' do
            
            customer = Customer.create(
                first_name: 'Cust',
                last_name: 'Omer'
            )

            merchant1 = Merchant.create(
                name: 'Jono'
            )

            merchant2 = Merchant.create(
                name: 'Dustin'
            )

            merchant3 = Merchant.create(
                name: 'Elysa'
            )

            invoice1 = Invoice.create(
                customer_id: customer.id,
                merchant_id: merchant1.id,
                status: 'shipped'
            )

            invoice2 = Invoice.create(
                customer_id: customer.id,
                merchant_id: merchant1.id,
                status: 'shipped'
            )

            invoice3 = Invoice.create(
                customer_id: customer.id,
                merchant_id: merchant2.id,
                status: 'returned'
            )

            invoice4 = Invoice.create(
                customer_id: customer.id,
                merchant_id: merchant3.id,
                status: 'packaged'
            )

            get "/api/v1/merchants/#{merchant1.id}/invoices?status=shipped"

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(2)

            get "/api/v1/merchants/#{merchant2.id}/invoices?status=returned"

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(1)

            get "/api/v1/merchants/#{merchant3.id}/invoices?status=packaged"  

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(1)
        end

        it 'returns a "404" error when a merchant_id is invalid or not found' do

            merchant1 = Merchant.create(
                name: 'Jono'
            )

            merchant1.destroy

            get "/api/v1/merchants/#{merchant1.id}/invoices"

            expect(response.status).to eq(404)

            expect{ Merchant.find(:id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
    end
end