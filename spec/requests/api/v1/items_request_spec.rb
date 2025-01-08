require 'rails_helper'

describe 'Items', type: :request do
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