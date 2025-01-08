class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  def id
    object.id.to_s
  end
end