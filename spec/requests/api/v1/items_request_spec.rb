require 'rails_helper'

RSpec.describe "Item endpoints", type: :request do
  describe 'Items' do
    it 'lists all items in the database' do

        merchant = Merchant.create(
            name: 'Jono'
        )

        item1 = Item.create(
            name: "Item Nemo Facere",
            description: "Sunt eum id eius magni consequuntur delectus veritatis. Quisquam laborum illo ut ab. Ducimus in est id voluptas autem.",
            unit_price: 42.91,
            merchant_id: merchant.id
        )

        item2 = Item.create(
            name: "Item Expedita Aliquam",
            description: "Voluptate aut labore qui illum tempore eius. Corrupti cum et rerum. Enim illum labore voluptatem dicta consequatur. Consequatur sunt consequuntur ut officiis.",
            unit_price: 687.23,
            merchant_id: merchant.id
        )

        item3 = Item.create(
            name: "Item Provident At",
            description: "Numquam officiis reprehenderit eum ratione neque tenetur. Officia aut repudiandae eum at ipsum doloribus. Iure minus itaque similique. Ratione dicta alias asperiores minima ducimus nesciunt at.",
            unit_price: 159.25,
            merchant_id: merchant.id
        )

        get "/api/v1/items"

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)
        expect(items[:data].length).to eq(3)
        expect(items[:meta][:count]).to eq(3)
        
        items[:data].each do |item|
            expect(item).to have_key(:id)
            expect(item[:id]).to be_an(String)

            expect(item[:attributes]).to have_key(:name)
            expect(item[:attributes][:name]).to be_a(String)

            expect(item[:attributes]).to have_key(:description)
            expect(item[:attributes][:description]).to be_a(String)

            expect(item[:attributes]).to have_key(:unit_price)
            expect(item[:attributes][:unit_price]).to be_a(Float)

            expect(item[:attributes]).to have_key(:merchant_id)
            expect(item[:attributes][:merchant_id]).to be_an(Integer)
        end
    end

    it 'sorts items based on unit_price from lowest to highest' do

        merchant = Merchant.create(
            name: 'Jono'
        )

        item1 = Item.create(
            name: "Item Nemo Facere",
            description: "Sunt eum id eius magni consequuntur delectus veritatis. Quisquam laborum illo ut ab. Ducimus in est id voluptas autem.",
            unit_price: 42.91,
            merchant_id: merchant.id
        )

        item2 = Item.create(
            name: "Item Expedita Aliquam",
            description: "Voluptate aut labore qui illum tempore eius. Corrupti cum et rerum. Enim illum labore voluptatem dicta consequatur. Consequatur sunt consequuntur ut officiis.",
            unit_price: 687.23,
            merchant_id: merchant.id
        )

        item3 = Item.create(
            name: "Item Provident At",
            description: "Numquam officiis reprehenderit eum ratione neque tenetur. Officia aut repudiandae eum at ipsum doloribus. Iure minus itaque similique. Ratione dicta alias asperiores minima ducimus nesciunt at.",
            unit_price: 159.25,
            merchant_id: merchant.id
        )

        get "/api/v1/items?sorted=price"

        expect(response).to be_successful

        items = JSON.parse(response.body, symbolize_names: true)
        
        expect(items[:data].length).to eq(3)
        expect(items[:meta][:count]).to eq(3)
        
        expect(items[:data].first[:id]).to eq(item1[:id].to_s)
        expect(items[:data].last[:id]).to eq(item2[:id].to_s)
    end
  end
  
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

  describe "PUT /items/:id" do
    xit 'can update the corresponding item with whichever details are provided by the user' do
      merchant1 = Merchant.create(
        name: 'Jono'
      )

      item1 = Item.create(
        name: 'Desk Lamp',
        description: 'make bright',
        unit_price: 5.99,
        merchant_id: merchant1.id

      )
      
      id = item1.id
      previous_name = item1.name

      item_params = {name: 'a stick'}
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item1 = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item1.name).to_not eq(previous_name)
      expect(item1.name).to eq('a stick')
    end
  end
end
