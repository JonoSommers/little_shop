require 'rails_helper'

describe 'Merchants', type: :request do
    it 'lists all merchants in the database' do

        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        get "/api/v1/merchants"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants[:data].length).to eq(3)
        expect(merchants[:meta][:count]).to eq(3)

        merchants[:data].each do |merchant|
            expect(merchant).to have_key(:id)
            expect(merchant[:id]).to be_an(String)

            expect(merchant[:attributes]).to have_key(:name)
            expect(merchant[:attributes][:name]).to be_a(String)
        end
    end

    it 'lists all merchants in the database' do

        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        get "/api/v1/merchants?sorted=age"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].length).to eq(3)
        expect(merchants[:meta][:count]).to eq(3)

        expect(merchants[:data].first[:id]).to eq(merchant1[:id].to_s)
        expect(merchants[:data].last[:id]).to eq(merchant3[:id].to_s)
    end
end