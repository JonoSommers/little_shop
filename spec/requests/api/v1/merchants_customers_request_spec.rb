require 'rails_helper'

describe 'MerchantsCustomers Endpoints', type: :request do
  describe 'GET merchants/:merchant_id/customers' do
    it 'returns all customers from a given merchant id' do
      merchant = Merchant.create(name: "Lula Faye") 
      customer1 = Customer.create(first_name: "John", last_name: "Doe")
      customer2 = Customer.create(first_name: "Jane", last_name: "Smith")
      Invoice.create(merchant_id: merchant.id, customer_id: customer1.id)
      Invoice.create(merchant_id: merchant.id, customer_id: customer2.id)

      get "/api/v1/merchants/#{merchant.id}/customers"
      
      customers = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      customers_data = customers[:data]

      expect(customers_data).to be_an(Array)
      expect(customers_data.size).to eq(2)

      customer1_data = customers_data.first
      customer2_data = customers_data.last

      expect(customer1_data[:attributes][:first_name]).to eq("John")
      expect(customer1_data[:attributes][:last_name]).to eq("Doe")
      expect(customer2_data[:attributes][:first_name]).to eq("Jane")
      expect(customer2_data[:attributes][:last_name]).to eq("Smith")
    end
  end
end