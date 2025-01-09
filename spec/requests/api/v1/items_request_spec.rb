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
  
  describe "POST /item" do
    it 'can create an item' do
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

  describe "DELETE /items/:id" do
    before(:each) do
      @merchant = Merchant.create( name: "Lula Faye")
      @item1 = Item.create(  name: "Crochet Hook", description: "5mm hook", unit_price: 5.99, merchant_id: @merchant.id )
      @item2 = Item.create( name: "Cashmere Yarn", description: "A teal green yarn", unit_price: 19.99, merchant_id: @merchant.id )
      @customer1 = Customer.create( first_name: "Cara", last_name: "Jones" )
      @invoice1 = Invoice.create( customer_id: @customer1.id, merchant_id: @merchant.id, status: "sent" )
      @invoice_item = InvoiceItem.create( item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: @item1.unit_price )
    end

    it 'can delete a select item' do
      expect(Item.all.length).to eq(2)

      delete "/api/v1/items/#{@item1.id}"

      expect(Item.all.length).to eq(1)
      expect{ Item.find(@item1.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'can cascade delete child records when an item is deleted' do
      expect(InvoiceItem.all).to eq([@invoice_item])

      delete "/api/v1/items/#{@item1.id}"

      expect{ InvoiceItem.find(@invoice_item.id)}.to raise_error(ActiveRecord::RecordNotFound)

      # Will want to add functionality that will change the invoice status to "item unavailable"
    end
  end
end