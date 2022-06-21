# モジュールだよ
module MakeDataModule
  extend ActiveSupport::Concern

  def make_line_graph_plot_data(line_graph_data)
    hash_list = []
    hash = {}
    label_list = []
    average_list = []
    median_list = []
    mode_list = []
    line_graph_data.each do |u|
      date = u.created_at.strftime('%Y-%m-%d')
      label_list.push(date)
      average_list.push(u.average)
      median_list.push(u.median)
      mode_list.push(u.mode)
      # hash['label'] = ''
      # hash['data'] ||= []
      # hash['data'].push u.
    end
    { labels: label_list, average: average_list, median: median_list, mode: mode_list }
  end

  def make_histogram_data(sold_array, type, search_condition)
    price_array = type == 'line' ? make_line_graph_data(sold_array) : make_hist_data(sold_array)

    return if price_array.blank?

    price_array.sort!
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
    hash_array = []

    Range.new(1, bins).each do |i|
      min = start_price + (i - 1) * bin_range
      max = start_price + i * bin_range
      filter_array = if i == bins
                       price_array.select { |x| x >= min }.select { |x| x <= max }
                     else
                       price_array.select { |x| x >= min }.select { |x| x < max }
                     end

      label = "¥#{min} ~ ¥#{max}"
      label_array.push(label)
      frequency = filter_array.length
      data_array.push(frequency)
      kaikyuchi = (min + max) / 2
      hash = { kaikyuchi:, frequency: }
      hash_array.push(hash)
    end
    total = price_array.inject(:+)
    median = price_array.size.even? ? price_array[price_array.size / 2 - 1, 2].inject(:+) / 2 : price_array[price_array.size / 2]
    max_freq = hash_array.max_by { |elem| elem[:frequency] }[:frequency]

    max_freq_array = hash_array.select { |elem| elem[:frequency] == max_freq }
    average = total / price_array.size
    mode = max_freq_array.min_by { |elem| (elem[:kaikyuchi] - average).abs }[:kaikyuchi]
    # puts "最小値:\t#{price_array.min}"
    # puts "最大値:\t#{price_array.max}"
    # puts "総計値:\t#{total}"
    # puts "平均値:\t#{total / price_array.size}"
    # puts "中央値:\t#{median}"
    # puts "最頻値:\t#{mode}"
    # print(hash_array)
    # print(price_array)
    print(price_array.length)
    print(data_array.inject(:+))

    if type == 'line'
      line_graph_datum = LineGraphDatum.new(average:, median:, mode:)
      search_condition.line_graph_data << line_graph_datum
    end
    [data_array, label_array]
  end

  def make_hist_data(sold_array)
    filtered_array = sold_array.select { |elem| elem[0] >= Time.zone.now.beginning_of_day }
    filtered_array.map { |elem| elem[1] }.compact
  end

  def make_line_graph_data(sold_array)
    sorted_array = sold_array.sort_by { |x| x[3] }
    sorted_array.select! { |elem| elem[0] >= Time.zone.now.beginning_of_day }
    # 新着順の上位３0個のみ抽出
    slice_num = (sold_array.length * 0.3).round
    sorted_array.slice!(slice_num, sold_array.length - slice_num) if sold_array.length > 30
    sorted_array.map { |elem| elem[1] }.compact
  end

  def mround(numerical)
    multiple = if numerical >= 2000
                 1000
               elsif numerical >= 500
                 500
               else
                 100
               end
    ((numerical / multiple.to_f).ceil(1) * multiple).to_i
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
