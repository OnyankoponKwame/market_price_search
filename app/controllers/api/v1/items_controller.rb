class Api::V1::ItemsController < ApiController
  include ScrapingModule
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

    # search_word = 'ブラッキー SA'
    search_condition = SearchCondition.find_by(keyword: search_word)
    nothing_flag = false
    result = true
    if search_condition
      # その日に検索されていたら検索しない
      result, nothing_flag = scrape(search_condition) unless search_condition.updated_at >= Time.zone.now.beginning_of_day
    else
      search_condition = SearchCondition.new(keyword: search_word)
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
      Array[item.updated_at.strftime('%Y-%m-%d'), item.price, item.url] if satisfy_conditions?(item.name, search_word, negative_keyword, include_title_flag)
    end.compact
    # 外れ値除外
    sale_array = outlier_detection(sale_array, price_min, price_max)
    sold_array = outlier_detection(sold_array, price_min, price_max)

    # ヒストグラム用データ
    data_array, label_array = make_histogram_data(sold_array)
    items_serialized = ItemResource.new(items).serialize
    data = { sale_array: sale_array.as_json, sold_array: sold_array.as_json, data_array: data_array.as_json, label_array: label_array.as_json, items: items_serialized }

    if sale_array.present? || sold_array.present?
      render json: data
    else
      head :not_found
    end
  end

  private

  def make_histogram_data(sold_array)
    price_array = make_price_array(sold_array)
    return if price_array.blank?

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

      label = "¥#{min} ~ ¥#{max}"
      label_array.push(label)
      frequency = filter_array.length
      data_array.push(frequency)
    end
    [data_array, label_array]
  end

  def make_price_array(sold_array)
    # 同じurlが含まれないよう日付を降順にしてユニークにする。
    sorted_array = sold_array.sort_by { |x| x[0] }.reverse
    uniq_sold_array = sorted_array.uniq(&:last)
    # 直近一週間のデータの価格を取得
    one_week_ago_day = (Time.current.at_beginning_of_day - 7.day).at_beginning_of_day
    uniq_sold_array.map { |elem| elem[1] if Date.parse(elem[0]) >= one_week_ago_day }.compact
  end

  def mround(numerical)
    multiple = if numerical >= 2000
                 1000
               elsif numerical >= 500
                 500
               else
                 100
               end
    # (numerical / multiple.to_f).round * multiple
    (numerical / multiple.to_f).floor * multiple
  end

  # 外れ値検出
  def outlier_detection(item_array, price_min, price_max)
    return item_array if item_array.blank? || item_array.length <= 10

    item_array.sort_by! { |x| x[1] }
    q1 = item_array[(item_array.length * 0.25).round][1]
    q3 = item_array[(item_array.length * 0.75).round][1]

    iqr = q3 - q1
    # 外れ値基準の下限を取得
    bottom = price_min.present? ? price_min : q1 - (1.5 * iqr)
    # 外れ値基準の上限を取得
    up = price_max.present? ? price_max : q3 + (1.5 * iqr)

    item_array.select! { |x| x[1] <= up }
    item_array.select! { |x| x[1] >= bottom }

    item_array
  end

  def satisfy_conditions?(item_name, search_word, negative_keyword, include_title_flag)
    flag = ActiveRecord::Type::Boolean.new.cast(include_title_flag)
    if flag
      search_word.split(/[[:blank:]]+/).each do |word|
        return false unless item_name.include?(word)
      end
    end
    if negative_keyword.present?
      negative_keyword.split(/[[:blank:]]+/).each do |word|
        return false if item_name.include?(word)
      end
    end
    true
  end
end
