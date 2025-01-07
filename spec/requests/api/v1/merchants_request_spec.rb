require 'rails_helper'

describe "Merchants", type: :request do
  it 'can create a merchant' do
    merchant_params = {
      "name": "Amazon"
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant: merchant_params)

    expect(response).to be_successful

    new_merchant = Merchant.last

    expect(new_merchant.id).to be_an(Integer)
    expect(new_merchant.name).to eq(merchant_params[:name])
  end
end