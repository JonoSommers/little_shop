class Api::V1::ItemsController < ApplicationController
  def show
    render json: ItemSerializer.new(Item.find(params[:id])).serializable_hash
  end
  
  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: :created
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end