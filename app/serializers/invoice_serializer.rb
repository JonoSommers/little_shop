class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :customer_id, :merchant_id, :status

  def id
    object.id.to_s
  end
end