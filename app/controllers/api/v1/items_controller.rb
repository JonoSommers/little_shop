class Api::V1::ItemsController < ApplicationController
  def index
      items = Item.all
      options = {}
      options[:meta] = {count: items.count}

      if params[:sorted] == 'price'
          items = items.order(:unit_price)
      end

      render json: ItemSerializer.new(items, options)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id])).serializable_hash
  end
  
  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: :created
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end