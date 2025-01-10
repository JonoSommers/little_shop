class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :item_count, if: Proc.new {|merchant, params| params[:item_count] == 'true'} do |merchant|
    merchant.items.count
  end
end