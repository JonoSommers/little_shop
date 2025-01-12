require 'rails_helper'

RSpec.describe "Invoice endpoints", type: :request do
    describe 'Invoices' do
        it 'renders a JSON representation of all invoices for a given merchant that have a status of shipped' do
            customer = Customer.create(first_name: 'Cust', last_name: 'Omer')
            merchant1 = Merchant.create(name: 'Jono')
            invoice1 = Invoice.create(customer_id: customer.id, merchant_id: merchant1.id, status: 'shipped')
            invoice2 = Invoice.create(customer_id: customer.id, merchant_id: merchant1.id, status: 'shipped')

            get "/api/v1/merchants/#{merchant1.id}/invoices?status=shipped"

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(2)
            expect(invoice1.merchant_id).to eq(merchant1.id)
            expect(invoice2.merchant_id).to eq(merchant1.id)
        end

        it 'renders a JSON representation of all invoices for a given merchant that have a status of returned' do
            customer = Customer.create(first_name: 'Cust', last_name: 'Omer')
            merchant2 = Merchant.create(name: 'Dustin')
            invoice3 = Invoice.create(customer_id: customer.id, merchant_id: merchant2.id, status: 'returned')

            get "/api/v1/merchants/#{merchant2.id}/invoices?status=returned"

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(1)
            expect(invoice3.merchant_id).to eq(merchant2.id)
        end

        it 'renders a JSON representation of all invoices for a given merchant that have a status of packaged' do
            customer = Customer.create(first_name: 'Cust', last_name: 'Omer')
            merchant3 = Merchant.create(name: 'Elysa')
            invoice4 = Invoice.create(customer_id: customer.id, merchant_id: merchant3.id, status: 'packaged')

            get "/api/v1/merchants/#{merchant3.id}/invoices?status=packaged"  

            expect(response).to be_successful

            invoices = JSON.parse(response.body, symbolize_names: true)

            expect(invoices[:data].length).to eq(1)
            expect(invoice4.merchant_id).to eq(merchant3.id)
        end

        it 'returns a "404" error when a merchants id is invalid or not found' do
            merchant1 = Merchant.create(name: 'Jono')

            merchant1.destroy
            
            get "/api/v1/merchants/#{merchant1.id}/invoices"
            
            expect(response.status).to eq(404)
            expect{ Merchant.find(merchant1.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
    end
end