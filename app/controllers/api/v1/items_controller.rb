class Api::V1::ItemsController < ApiController
  include ScrapingModule
  include MakeDataModule
  require './app/commonclass/item_resource'

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    head :not_found
  end

  def index
    search_word = params[:keyword]
    # nonzeroは0のときにnilを返し、そうでない場合は自身を返す
    price_min = params[:price_min].to_i.nonzero?
    price_max = params[:price_max].to_i.nonzero?
    negative_keyword = params[:negative_keyword]
    include_title_flag = params[:include_title_flag]
    # テスト用
    # search_word = 'ブラッキー SA'
    search_condition = SearchCondition.find_by(keyword: search_word, price_min:, price_max:)
    scanned_flag = false
    if search_condition
      scanned_flag = search_condition.updated_at >= Time.zone.now.beginning_of_day
      # その日に検索されていたら検索しない
      result, nothing_flag = scrape(search_condition) unless scanned_flag
    else
      search_condition = SearchCondition.new(keyword: search_word, price_min:, price_max:, negative_keyword:, include_title_flag:)
      result, nothing_flag = scrape(search_condition)
      # エラーでなく出品ありの場合のみ保存
      search_condition.save if result && !nothing_flag
    end

    return render json: { message: '出品された商品がありません' }, status: :ok if nothing_flag
    return head :not_found unless result

    items = search_condition.items

    sale_array = items.sale.price_filtered(price_min, price_max).map do |item|
      Array[item.updated_at.strftime('%Y-%m-%d'), item.price, item.url] if satisfy_conditions?(item.name, search_word, negative_keyword, include_title_flag)
    end.compact
    sold_array = items.sold.price_filtered(price_min, price_max).map do |item|
      Array[item.updated_at.strftime('%Y-%m-%d'), item.price, item.url, item.pos] if satisfy_conditions?(item.name, search_word, negative_keyword, include_title_flag)
    end.compact

    # 外れ値除外
    sale_array = outlier_detection(sale_array, price_min, price_max)
    sold_array = outlier_detection(sold_array, price_min, price_max)

    # ヒストグラム用データ
    data_array, label_array = make_histogram_data(sold_array, 'hist', nil)
    # 折れ線グラフデータ
    make_histogram_data(sold_array, 'line', search_condition) unless scanned_flag

    line_graph_data = search_condition.line_graph_data.order(created_at: :asc)
    line_graph_plot_data = make_line_graph_plot_data(line_graph_data)
    items_serialized = ItemResource.new(items).serialize
    data = { sale_array: sale_array.as_json, sold_array: sold_array.as_json, data_array: data_array.as_json, label_array: label_array.as_json, line_graph_data: line_graph_plot_data.as_json, items: items_serialized }

    if sale_array.present? || sold_array.present?
      render json: data
    else
      head :not_found
    end
  end
end
