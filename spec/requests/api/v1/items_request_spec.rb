require 'rails_helper'

RSpec.describe "Item endpoints" do

  describe "FETCH /items/:id" do
    it 'can fetch a single record at a specific id' do
      id = Item.create( name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: 1 )

      get "api/v1/items/#{id}"

      item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(Integer)

      expect(item).to have_key(:name)
      expect(item[:name]).to be_a(String)
      expect(item[:name]).to eq('Crochet Hook')

      expect(item).to have_key(:description)
      expect(item[:description]).to be_a(String)
      expect(item[:description]).to eq('5mm hook')

      expect(item).to have_key(:unit_price)
      expect(item[:unit_price]).to be_a(Float)
      expect(item[:unit_price]).to eq(5.99)

      expect(item).to have_key(:merchant_id)
      expect(item[:merchant_id]).to be_a(Integer)
      expect(item[:merchant_id]).to eq(1)
    end
  end
end