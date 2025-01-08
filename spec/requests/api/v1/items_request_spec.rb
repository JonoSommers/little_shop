require 'rails_helper'

RSpec.describe "Item endpoints", type: :request do

  describe "FETCH /items/:id" do
    it 'can fetch a single record at a specific id' do
      merchant_id = Merchant.create( name: "Lula Faye").id
      id = Item.create( name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: merchant_id ).id.to_s
      
      get "/api/v1/items/#{id}"

      item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      itemData = item[:data]

      expect(itemData).to have_key(:id)
      expect(itemData[:id]).to be_an(String)

      expect(itemData[:attributes]).to have_key(:name)
      expect(itemData[:attributes][:name]).to be_a(String)
      expect(itemData[:attributes][:name]).to eq('Crochet Hook')

      expect(itemData[:attributes]).to have_key(:description)
      expect(itemData[:attributes][:description]).to be_a(String)
      expect(itemData[:attributes][:description]).to eq('5mm hook')

      expect(itemData[:attributes]).to have_key(:unit_price)
      expect(itemData[:attributes][:unit_price]).to be_a(Float)
      expect(itemData[:attributes][:unit_price]).to eq(5.99)

      expect(itemData[:attributes]).to have_key(:merchant_id)
      expect(itemData[:attributes][:merchant_id]).to be_a(Integer)
      expect(itemData[:attributes][:merchant_id]).to eq(merchant_id)
    end
  end
end