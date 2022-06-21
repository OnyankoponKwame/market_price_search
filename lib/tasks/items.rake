namespace :items do
  require Rails.root.join('app/controllers/concerns/scraping_module')
  require Rails.root.join('app/controllers/concerns/make_data_module')
  include ScrapingModule
  include MakeDataModule
  desc 'search_conditionに紐づく商品情報を取得して更新'
  task update_items: :environment do
    search_conditions = SearchCondition.where(cron_flag: true)
    # 今日すでに更新されているものは除外
    rejected_search_conditions = search_conditions.reject { |elem| elem.updated_at >= Time.zone.now.beginning_of_day }
    rejected_search_conditions.each do |search_condition|
      print("検索:#{search_condition.keyword}\n")
      scrape(search_condition)
      items = search_condition.items
      sold_array = items.sold.price_filtered(search_condition.price_min, search_condition.price_max).map do |item|
        Array[item.updated_at.strftime('%Y-%m-%d'), item.price, item.url, item.pos] if satisfy_conditions?(item.name, search_condition.keyword, search_condition.negative_keyword, search_condition.include_title_flag)
      end.compact
      sold_array = outlier_detection(sold_array, search_condition.price_min, search_condition.price_max)
      make_histogram_data(sold_array, 'line', search_condition)
    rescue Selenium::WebDriver::Error::TimeoutError => e
      print("Timeout検索キーワード：#{search_condition}\n")
      Rails.logger.debug "Timeout検索キーワード：#{search_condition}"
      Rails.logger.error e
      next
    rescue StandardError => e
      Rails.logger.error e
      print(e)
      next
    end
  end
end
