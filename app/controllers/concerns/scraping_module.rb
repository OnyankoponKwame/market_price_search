# モジュールだよ
module ScrapingModule
  extend ActiveSupport::Concern
  require 'selenium-webdriver'

  BASE_URL = 'https://www.mercari.com/jp/search/?sort_order=&keyword='
  OPTIONS = Selenium::WebDriver::Chrome::Options.new
  OPTIONS.add_argument('--headless')

  def scrape(search_condition)
    driver = Selenium::WebDriver.for :chrome, capabilities: [OPTIONS]
    # :timeoutオプションは秒数を指定している。この場合は100秒
    wait = Selenium::WebDriver::Wait.new(timeout: 100)
    get(driver, wait, search_condition)
  rescue Selenium::WebDriver::Error::TimeoutError => e
    Rails.logger.debug "Timeout検索キーワード：#{search_condition.keyword}"
    Rails.logger.error e
  ensure
    driver.quit
  end

  def scrape_rake(search_conditions)
    driver = Selenium::WebDriver.for :chrome, capabilities: [OPTIONS]
    # :timeoutオプションは秒数を指定している。この場合は100秒
    wait = Selenium::WebDriver::Wait.new(timeout: 4)
    search_conditions.each do |search_condition|
      get(driver, wait, search_condition)
    rescue Selenium::WebDriver::Error::TimeoutError => e
      # debugger
      Rails.logger.debug "Timeout検索キーワード：#{search_condition.keyword}"
      Rails.logger.error e
      next
    end
    driver.quit
  end

  def get(driver, wait, search_condition)
    driver.get(BASE_URL + search_condition.keyword)
    # untilメソッドは文字通り「～するまで」を意味する
    wait.until { driver.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt') }
    elements = driver.find_elements(:xpath, "//*[@data-testid='item-cell']")
    save_items(elements, search_condition)
    search_condition.touch
  end

  def save_items(elements, search_condition)
    elements.each do |element|
      item = Item.new
      item.name = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('alt').gsub('のサムネイル', '')
      item.price = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('price')
      item.url = element.find_element(:tag_name, 'a').attribute('href')
      item.sold = element.find_element(:tag_name, 'mer-item-thumbnail').attribute('sticker').blank? ? :sale : :sold
      search_condition.items << item
    end
    search_condition.save
  end
end
