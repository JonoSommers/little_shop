class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
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

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item)
    else
      render json: { error: item.errors.full_messages }, status: :not_found
    end
  end
  
  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: :created
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  def find_all
    options = {}
    if params[:min_price].present? && params[:max_price].present?
      min_price = params[:min_price]
      max_price = params[:max_price]
      items = Item.where(unit_price: min_price..max_price).order(:unit_price)
      options[:meta] = {count: items.count}
      render json: ItemSerializer.new(items, options)

    elsif params[:min_price] == "#{params[:min_price]}"
      items = Item.where("unit_price >= ?", params[:min_price]).order(:unit_price)
      options[:meta] = {count: items.count}
      render json: ItemSerializer.new(items, options)

    elsif params[:max_price] == "#{params[:max_price]}"
      items = Item.where("unit_price <= ?", params[:max_price]).order(:unit_price)
      options[:meta] = {count: items.count}
      render json: ItemSerializer.new(items, options)

    elsif params[:name] == "#{params[:name]}"
      items = Item.where("name ILIKE ?", "%#{params[:name]}%").order(:name)
      options[:meta] = {count: items.count}
      render json: ItemSerializer.new(items, options)
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def record_not_found(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :not_found
  end
end