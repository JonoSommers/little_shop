class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotDestroyed, with: :render_unprocessable_entity 
  
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
    if params[:name].present? && params[:min_price].present?
      render json: {}, status: :bad_request

    elsif params[:name].present? && params[:max_price].present?
      render json: {}, status: :bad_request

    elsif params[:min_price].present? && params[:max_price].present?
      if (params[:min_price].to_f  < 0) || (params[:max_price].to_f  < 0)
        render json: {}, status: :bad_request
      else
        min_price = params[:min_price]
        max_price = params[:max_price]
        items = Item.where(unit_price: min_price..max_price).order(:unit_price)
        options[:meta] = {count: items.count}
        render json: ItemSerializer.new(items, options)
      end

    elsif params[:min_price].present?
      if params[:min_price].to_f < 0
        render json: { errors: {} }, status: :bad_request
      else
        items = Item.where("unit_price >= ?", params[:min_price]).order(:unit_price)
        options[:meta] = {count: items.count}
        render json: ItemSerializer.new(items, options)
      end

    elsif params[:max_price].present?
      if params[:max_price].to_f < 0
        render json: { errors: {} }, status: :bad_request
      else
        items = Item.where("unit_price <= ?", params[:max_price]).order(:unit_price)
        options[:meta] = {count: items.count}
        render json: ItemSerializer.new(items, options)
      end

    elsif params[:name].present?
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

  def render_unprocessable_entity(exception)
    render json: { message: exception.message, errors: [exception.message] }, status: :unprocessable_entity
  end
end