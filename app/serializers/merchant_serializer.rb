class MerchantSerializer
  include JSONAPI::Serializer
  attributes :id, :name
end