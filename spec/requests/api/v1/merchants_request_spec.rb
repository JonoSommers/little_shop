require 'rails_helper'

describe "Merchants", type: :request do
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