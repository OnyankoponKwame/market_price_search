namespace :items do
  include ScrapingModule
  desc 'search_conditionに紐づく商品情報を取得して更新'
  task update_items: :environment do
    search_conditions = SearchCondition.where(cron_flag: true)
    scrape_rake(search_conditions)
  end
end
