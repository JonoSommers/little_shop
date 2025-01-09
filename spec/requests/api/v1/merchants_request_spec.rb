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
    it 'can delete a select merchant' do
      merchant1 = Merchant.create( name: "Lula Faye")
      merchant2 = Merchant.create( name: "Michaels Craft Store")

      expect(Merchant.all.length).to eq(2)

      delete "/api/v1/merchants/#{merchant2.id}"

      expect(Merchant.all.length).to eq(1)
      expect{ Merchant.find(merchant2.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  desctibe "PATCH /merchants/:id" do
    it 'can update the corresponding merchant with whichever details are provided by the user' do
      merchant1 = Merchant.create(
        name: 'Jono'
      )
      id = merchant1.id
      previous_name = merchant1.name

      merchant_params = {name: 'Merlin'}
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/posters/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      merchant1 = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(merchant1.name).to_not eq(previous_name)
      expect(merchant1.name).to eq('Merlin')
    end
  end
end