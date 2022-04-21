class Api::V1::ItemsController < ApiController
  include ScrapingModule
  # ActiveRecordのレコードが見つからなければ404 not foundを応答する
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: { error: '404 not found' }, status: 404
  end

  def index
    search_words = 'ブラッキー SA'
    search_condition = SearchCondition.create(keyword: search_words)
    scrape(search_condition)
    items = Item.all
    # hash = items.sale.map { |item| Array[item.id, item.price] }.to_json
    hash = items.sale.map { |item| Array[item.updated_at.strftime('%Y-%m-%d'), item.price] }.to_json

    render json: hash
  end
end
