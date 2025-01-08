require 'rails_helper'

describe "Items", type: :request do
  it 'can create a poster' do
    merchant = Merchant.create!(name: "Test Merchant")
    item_params = {
      "name": "Banana",
      "description": "a yellow fruit",
      "unit_price": 0.99,
      "merchant_id": merchant.id
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    expect(response).to be_successful
    expect(response).to have_http_status(:created)
    
    new_item = Item.last

    expect(new_item.name).to eq(item_params[:name])
    expect(new_item.description).to eq(item_params[:description])
    expect(new_item.unit_price).to eq(item_params[:unit_price])
    expect(new_item.merchant_id).to eq(item_params[:merchant_id])
  end
end