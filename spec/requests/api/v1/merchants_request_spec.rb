require 'rails_helper'

RSpec.describe "Merchant endpoints", type: :request do
  describe "GET /merchants/:id" do
    it 'can fetch a single record at a specific id' do
      id = Merchant.create( name: "Lula Faye" ).id.to_s

      get "/api/v1/merchants/#{id}"
      
      merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful

      merchantData = merchant[:data]

      expect(merchantData).to have_key(:id)
      expect(merchantData[:id]).to be_a(String)
     
      expect(merchantData[:attributes]).to have_key(:name)
      expect(merchantData[:attributes][:name]).to be_a(String)
      expect(merchantData[:attributes][:name]).to eq('Lula Faye')
    end
  end
  
  describe "POST /merchant" do
    it 'can create a merchant' do
      merchant_params = {
        "name": "Amazon"
      }

      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

      expect(response).to be_successful
      expect(response).to have_http_status(:created)

      new_merchant = Merchant.last

      expect(new_merchant.id).to be_an(Integer)
      expect(new_merchant.name).to eq(merchant_params[:name])
    end

    it 'will not save a merchant that is missing attributes' do
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants", headers: headers, params: JSON.generate({})

      expect(response).to_not be_successful
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'will not save a merchant that has blank attributes' do
      merchant_params = {
        "name": ""
      }

      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

      expect(response).to_not be_successful
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /merchants/:id" do
    before(:each) do
      @merchant1 = Merchant.create( name: "Lula Faye")
      @merchant2 = Merchant.create( name: "Michaels Craft Store")

      @item1 = Item.create(  name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: @merchant1.id )
      @item2 = Item.create( name: "Cashmere Yarn", description: "A teal green yarn", unit_price: 19.99, merchant_id: @merchant1.id )
    end

    it 'can delete a select merchant' do
      expect(Merchant.all.length).to eq(2)

      delete "/api/v1/merchants/#{@merchant2.id}"

      expect(Merchant.all.length).to eq(1)
      expect{ Merchant.find(@merchant2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'will delete all child records when select merchant is deleted' do
      expect(@merchant1.items).to eq([@item1, @item2])
      
      # require 'pry'; binding.pry
      delete "/api/v1/merchants/#{@merchant1.id}"
      expect{ Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Item.find(@item2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end