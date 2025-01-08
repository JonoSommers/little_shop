require 'rails_helper'

RSpec.describe "Merchant endpoints", type: :request do

  describe "FETCH /merchants/:id" do
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
end
