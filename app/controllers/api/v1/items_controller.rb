class Api::V1::ItemsController < ApiController
  include ScrapingModule
  # ActiveRecordのレコードが見つからなければ404 not foundを応答する
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: { error: '404 not found' }, status: 404
  end

  def index
    # search_words = params[:keyword]
    search_words = 'ブラッキー SA'
    search_condition = SearchCondition.find_by(keyword: search_words)
    unless search_condition
      search_condition = SearchCondition.create(keyword: search_words)
      scrape(search_condition)
    end
    items = search_condition.items
    sale_array = items.sale.map { |item| Array[item.updated_at.strftime('%Y-%m-%d'), item.price] }
    sold_array = items.sold.map { |item| Array[item.updated_at.strftime('%Y-%m-%d'), item.price] }
    # items.where(updated_at: (Time.current.at_beginning_of_day - 6.day).at_beginning_of_day..Time.current.at_end_of_day)
    price_array = []
    sold_array.each do |elem|
      one_week_ago_day = (Time.current.at_beginning_of_day - 6.day).at_beginning_of_day
      price_array.push(elem[1]) if Date.parse(elem[0]) >= one_week_ago_day
    end

    data_array, label_array = make_histogram_data(price_array)

    render json: { sale_array: sale_array.to_json, sold_array: sold_array.to_json, data_array: data_array, label_array: label_array }
  end

  private

  def search_params
    params.permit(:keyword)
  end

  def make_histogram_data(price_array)
    # price_array.select!{|x| x>=50000}
    # price_array.select!{|x| x<=90000}

    price_array.sort!

    q1 = price_array[(price_array.length * 0.25).round]
    q3 = price_array[(price_array.length * 0.75).round]
    iqr = q3 - q1

    # 外れ値基準の下限を取得
    bottom = q1 - (1.5 * iqr)
    # 外れ値基準の上限を取得
    up = q3 + (1.5 * iqr)

    price_array.select! { |x| x <= up }
    price_array.select! { |x| x >= bottom }

    min_price, max_price = price_array.minmax
    price_range = max_price - min_price
    length = price_array.length

    bins = (Math.log2(length) + 3).round

    bin_range = price_range / bins

    bin_range = mround(bin_range)

    label_array = []
    data_array = []

    start_price = mround(min_price)

    Range.new(1, bins).each do |i|
      min = start_price + (i - 1) * bin_range
      max = i == bins ? max_price : start_price + i * bin_range - 1
      filter_array = price_array.select { |x| x >= min }.select { |x| x <= max }

      label = "#{min} ~ #{max}"
      label_array.push(label)
      frequency = filter_array.length
      data_array.push(frequency)
    end
    puts data_array.sum
    puts length
    [data_array, label_array]
  end

  def mround(numerical)
    multiple = if numerical >= 1000
                 1000
               elsif numerical >= 500
                 500
               else
                 100
               end
    (numerical / multiple.to_f).round * multiple
  end
end
