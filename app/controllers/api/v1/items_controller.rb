class Api::V1::ItemsController < ApiController
  include ScrapingModule
  # ActiveRecordのレコードが見つからなければ404 not foundを応答する
  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render json: { error: '404 not found' }, status: 404
  end

  def index
    search_words = params[:keyword]
    # nonzeroは0のときにnilを返し、そうでない場合は自身を返す?
    price_min = params[:price_min].to_i.nonzero?
    price_max = params[:price_max].to_i.nonzero?

    search_words = 'ブラッキー SA'
    search_condition = SearchCondition.find_by(keyword: search_words)
    unless search_condition
      search_condition = SearchCondition.create(keyword: search_words)
      scrape(search_condition)
    end
    items = search_condition.items
    sale_array = items.sale.published(price_min, price_max).map { |item| Array[item.updated_at.strftime('%Y-%m-%d'), item.price] }
    sold_array = items.sold.published(price_min, price_max).map { |item| Array[item.updated_at.strftime('%Y-%m-%d'), item.price] }

    price_array = []
    sold_array.each do |elem|
      # one_week_ago_day = (Time.current.at_beginning_of_day - 6.day).at_beginning_of_day
      one_week_ago_day = Date.parse(elem[0])
      price_array.push(elem[1]) if Date.parse(elem[0]) >= one_week_ago_day
    end
    # ヒストグラム用データ
    data_array, label_array = make_histogram_data(price_array, price_min, price_max)

    render json: { sale_array: sale_array, sold_array: sold_array, data_array: data_array, label_array: label_array, items: items }
  end

  private

  def search_params
    params.permit(:keyword)
  end

  def make_histogram_data(price_array, price_min, price_max)
    # 外れ値検出
    price_array = outlier_detection(price_array, price_min, price_max)
    min_price, max_price = price_array.minmax
    price_range = max_price - min_price
    length = price_array.length

    # bins:階級の数,bin_range:階級の幅
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
    [data_array, label_array]
  end

  def mround(numerical)
    multiple = if numerical >= 2000
                 1000
               elsif numerical >= 500
                 500
               else
                 100
               end
    (numerical / multiple.to_f).round * multiple
  end

  def outlier_detection(price_array, price_min, price_max)
    price_array.sort!

    q1 = price_array[(price_array.length * 0.25).round]
    q3 = price_array[(price_array.length * 0.75).round]
    iqr = q3 - q1

    # 外れ値基準の下限を取得
    # bottom = q1 - (1.5 * iqr)
    bottom = price_min.present? ? price_min : q1 - (1.5 * iqr)
    # 外れ値基準の上限を取得
    # up = q3 + (1.5 * iqr)
    up = price_max.present? ? price_max : q3 + (1.5 * iqr)

    price_array.select! { |x| x <= up }
    price_array.select! { |x| x >= bottom }
    price_array
  end

  def integer_string?(str)
    Integer(str)
  rescue ArgumentError
  end
end
