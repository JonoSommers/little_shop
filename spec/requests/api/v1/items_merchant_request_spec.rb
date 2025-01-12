require 'rails_helper'

RSpec.describe 'Merchant_Items:', type: :request do
  describe "GET /items/:id/merchant" do
    before(:each) do
      @merchant1 = Merchant.create( name: "Lula Faye")
      @item1 = Item.create(  name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: @merchant1.id )
      @item2 = Item.create( name: "Cashmere Yarn", description: "A teal green yarn", unit_price: 19.99, merchant_id: @merchant1.id )
    end

    it 'can return the merchant of an item with specific id' do
      get "/api/v1/items/#{@item1.id}/merchant"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data][:id].to_i).to eq(@merchant1.id)
    end

    it 'returns a 404 status code if item is not found' do
      test_id = 10
      get "/api/v1/items/#{test_id}/merchant"

      expect{ Item.find(test_id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response.status).to eq(404) 
    end
  end
end