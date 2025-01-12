require 'rails_helper'

RSpec.describe 'Merchant_Items:', type: :request do
  describe "Get /merchants/:id/items" do
    before(:each) do
      @merchant1 = Merchant.create( name: "Lula Faye")
      @item1 = Item.create(  name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: @merchant1.id )
      @item2 = Item.create( name: "Cashmere Yarn", description: "A teal green yarn", unit_price: 19.99, merchant_id: @merchant1.id )
      @items_array = [@item1.id, @item2.id]
    end

    it 'can return all items associated with a merchant' do
      get "/api/v1/merchants/#{@merchant1.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)

      items[:data].each do |item| 
        expect(item[:id].to_i).to satisfy { |id| @items_array.include?(id) }
      end
    end

    it 'returns a 404 status code when merchant is not found' do
      test_id = 10
      get "/api/v1/merchants/#{test_id}/items"

      expect{ Merchant.find(test_id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response.status).to eq(404) 
    end
  end
end