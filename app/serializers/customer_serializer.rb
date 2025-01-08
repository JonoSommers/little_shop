class CustomerSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name

  def id
    object.id.to_s
  end
end