require 'rails_helper'

RSpec.describe "Merchant endpoints", type: :request do
  describe 'Merchants', type: :request do
    it 'lists all merchants in the database' do

        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        get "/api/v1/merchants"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)
        expect(merchants[:data].length).to eq(3)
        expect(merchants[:meta][:count]).to eq(3)

        merchants[:data].each do |merchant|
            expect(merchant).to have_key(:id)
            expect(merchant[:id]).to be_an(String)

            expect(merchant[:attributes]).to have_key(:name)
            expect(merchant[:attributes][:name]).to be_a(String)
        end
    end

    it 'lists all merchants in the database sorted by created_at' do

        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        get "/api/v1/merchants?sorted=age"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].length).to eq(3)
        expect(merchants[:meta][:count]).to eq(3)

        expect(merchants[:data].first[:id]).to eq(merchant1[:id].to_s)
        expect(merchants[:data].last[:id]).to eq(merchant3[:id].to_s)
    end

    it 'lists all merchants that have had items from an invoice returned' do

        customer = Customer.create(
            first_name: 'Jono',
            last_name: 'Sommers'
        )

        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        invoice1 = Invoice.create(
            customer_id: customer.id,
            merchant_id: merchant1.id,
            status: 'returned'
        )

        invoice1 = Invoice.create(
            customer_id: customer.id,
            merchant_id: merchant2.id,
            status: 'returned'
        )

        get "/api/v1/merchants?status=returned"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].length).to eq(2)
        expect(merchants[:meta][:count]).to eq(2)
        expect(merchants[:data].first[:id]).to eq(merchant1[:id].to_s)
        expect(merchants[:data].last[:id]).to eq(merchant2[:id].to_s)
    end

    it 'lists all the merchants with an added item_count attribute' do
        
        merchant1 = Merchant.create(
            name: 'Jono'
        )

        merchant2 = Merchant.create(
            name: 'Dustin'
        )

        merchant3 = Merchant.create(
            name: 'Elysa'
        )

        item1 = Item.create(
            name: "Item Nemo Facere",
            description: "Sunt eum id eius magni consequuntur delectus veritatis. Quisquam laborum illo ut ab. Ducimus in est id voluptas autem.",
            unit_price: 42.91,
            merchant_id: merchant1.id
        )

        item2 = Item.create(
            name: "Item Expedita Aliquam",
            description: "Voluptate aut labore qui illum tempore eius. Corrupti cum et rerum. Enim illum labore voluptatem dicta consequatur. Consequatur sunt consequuntur ut officiis.",
            unit_price: 687.23,
            merchant_id: merchant1.id
        )

        item3 = Item.create(
            name: "Item Provident At",
            description: "Numquam officiis reprehenderit eum ratione neque tenetur. Officia aut repudiandae eum at ipsum doloribus. Iure minus itaque similique. Ratione dicta alias asperiores minima ducimus nesciunt at.",
            unit_price: 159.25,
            merchant_id: merchant2.id
        )

        get "/api/v1/merchants?count=true"

        expect(response).to be_successful

        merchants = JSON.parse(response.body, symbolize_names: true)

        expect(merchants[:data].length).to eq(3)
        expect(merchants[:meta][:count]).to eq(3)

        expect(merchants[:data].first[:attributes][:item_count]).to eq(2)

        merchants[:data].each do |merchant|
            expect(merchant).to have_key(:id)
            expect(merchant[:id]).to be_a(String)

            expect(merchant[:attributes]).to have_key(:name)
            expect(merchant[:attributes][:name]).to be_a(String)

            expect(merchant[:attributes]).to have_key(:item_count)
            expect(merchant[:attributes][:item_count]).to be_an(Integer)
        end
    end
  end
  
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

  describe "PATCH /merchants/:id" do
    xit 'can update the corresponding merchant with whichever details are provided by the user' do
      merchant1 = Merchant.create(
        name: 'Jono'
      )
      id = merchant1.id
      previous_name = merchant1.name

      merchant_params = {name: 'Merlin'}
      headers = {"CONTENT_TYPE" => "application/json"}
      patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate({merchant: merchant_params})
      merchant1 = Merchant.find_by(id: id)

      expect(response).to be_successful
      expect(merchant1.name).to_not eq(previous_name)
      expect(merchant1.name).to eq('Merlin')
    end
  end
end
