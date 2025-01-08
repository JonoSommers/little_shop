class ItemSerializer
  include JSONAPI::Serializer
  
  attributes :name, :description, :unit_price

  def id
    object.id.to_s
  end
end