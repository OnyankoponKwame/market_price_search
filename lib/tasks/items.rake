namespace :items do
  require Rails.root.join("app/controllers/concerns/scraping_module")
  include ScrapingModule
  desc 'search_conditionに紐づく商品情報を取得して更新'
  task update_items: :environment do
    search_conditions = SearchCondition.where(cron_flag: true)
    scrape_rake(search_conditions)
  end
end
